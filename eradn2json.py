#!venv/bin/python3

import csv
import jsonpickle
import pprint
pp = pprint.PrettyPrinter(indent = 2)
import untangle
import sys

class Printable:
    def __repr__(self):
        from pprint import pformat
        return "<" + type(self).__name__ + "> " + pformat(vars(self), indent=4, width=100)

input_file = "eRADN/Daten/eRADN_TEST/eRADN_1696_20191202_091131_000.xml"

class Strecke(Printable):
    def __init__(self):
        self.id = None
        self.name = None
        self.bpe = []

class BP(Printable):
    def __init__(self):
        self.id = None
        self.name = None   # Abkuerzung (Text)
        self.km = 0.0

streckeList = []

inp = untangle.parse(input_file)
for strecke in inp.ns2_radn_daten.strecken.strecke:
    for teilstrecke in strecke.teilstrecken.teilstrecke:
        next_strecke = Strecke()
        next_strecke.id = teilstrecke["id"]
        next_strecke.name = "{} ({})".format(strecke["bezeichnung"], teilstrecke["bezeichnung"])
        real_km = 0.0
        prev_km = None
        we_are_the_first = True
        for bp in teilstrecke.teilstreckenBPe.teilstreckenBp:
            if not bp["km1"]: continue
            if we_are_the_first:
                if bp["km2"]:
                    prev_km = float(bp["km2"])
                else:
                    prev_km = float(bp["km1"])
                we_are_the_first = False
            else:
                real_km += abs(float(bp["km1"]) - prev_km)

            next_bp = BP()
            next_bp.id = bp["id"]
            next_bp.km = "{0:.1f}".format(real_km)
            next_bp.km1 = bp["km1"] or ""
            next_bp.km2 = bp["km2"] or ""
            if bp["km2"]:
                prev_km = float(bp["km2"])
            else:
                prev_km = float(bp["km1"])

            next_bp.name = bp["bpAbkuerzung"]
            next_strecke.bpe.append(next_bp)

        streckeList.append(next_strecke)

toptable = {}
topologie_file = "eRADN/Daten/topologie_20200131_0400.xml"
top = untangle.parse(topologie_file)
for bp in top.topo_TopologieDaten.betriebspunkt:
    try:
        if bp.bpAbkuerzung:
            pass
        toptable[bp.bpAbkuerzung.cdata] = bp.bezeichnung.cdata
    except:
        pass

writer = csv.writer(sys.stdout, delimiter=',', quotechar='"')
for strecke in streckeList:
    for bp in strecke.bpe:
        # TODO(errge): handle if toptable[bp.name] doesn't exist, but so far topologie was always complete
        writer.writerow([strecke.id, strecke.name, bp.id, bp.name, toptable[bp.name], bp.km, bp.km1, bp.km2])
    writer.writerow([])
    writer.writerow([])

# print(jsonpickle.encode(streckeList, unpicklable=False))
# pp.pprint(streckeList)
