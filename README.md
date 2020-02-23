# Routes

The goal of this project, is to add route data to Dreischeibe.  Using
the route data, the user should be able to build up pathings, save
those and compute the KM length for them.

We need to support importing route data from multiple providers:
e.g. SBB and by-hand entry.

In this document, we will discuss the data model and file formats.

# Terminology, entities

Provider: source of data input (e.g. "Walter manual entry" or "SBB
eRADN data").

BP (Betriebspunkt): station or other location on the track,
identified by a 4 letter combination, that is unique in Switzerland.

Strecke: a sequence of BPs with KM data.

Weg (we can change this, Eva+Gergely came up with this): a user-built
entity, a sequence of Strecke usages, on which we want to run a train
(or for some other reason, we are interested in the KM calculation).

Fahrt: a train operated on a Weg.

# DB Model

See `BP_DataDiagram.pdf` and `BP_DataDiagram.dbd`.  (Can be nicely
edited and formatted on the dbdiagram.io website.)

Provider table: representing a data provider.  Probably we will have
other attributes apart from "name", e.g. if we in the future want to
automatically download data periodically, then we could have a
download URL here or something similar.

BetriebsPunkt: represents a BP, id is the 4 letter Abkürzung, while
name is the offical name of the station.

Provider_BetriebsPunkt: N:M join table, so that the same topology data
can be interpreted from many providers.

Strecke: this table contains the description only, not the list of
BPs.  id is in format of `SS_25384` (coming from the import).  Name in
this table can provider a user friendly name for the Strecke (also
provided in the XML), e.g. "Genève Aéroport - / La Plaine - / Genève /
Ge-La Praille (LP - CHNE)".

Strecke_BPList: list of BPs (stations) in a Strecke.  We store the id
from XML (in format `SNN_2438_4341`).  And the KM data, being 0 at
station 0.  The `order` field defines the order of the BPs in the
Strecke, starting at 0.

Weg: this is what the user can build up on the UI, a combination of
Strecken to make a rideable path.

Weg_StreckeList: list of Strecken building up a Weg.  (strecke, von)
AND (strecke, bis) are foreign keys for the primary key of
`Strecke_BPList` (strecke, order).  The `order` field defines the
order of the Strecken in the Weg, starting at 0.

Fahrt: an instantionation of a Weg.  Can contain all necessary
metadata that we need, e.g. timestamp, type of vehicles involved, etc.

# SBB eRADN import

See `eradn2json.py`, this reads in the SBB data, filters it for the
fields that we actually want (BPs, KM data, Strecken), and then
outputs it in JSON or CSV.

This Python script will be reimplemented in PHP and instead of writing
to CSV will write the computed KM data with the imported BP names to
the database (once we agreed on the DB model).

# Manual entry

How the manual entry of Streckes should be implemented?  We will
surely need this, because the SBB data currently doesn't contain all
the stations and all the KM data for every track in Switzerland.
E.g. our line (Zurich Wiedikon-Adliswil-Sihlwald-Sihlbrugg) is not
in there.

I see two solutions: first would be UI in the webapp, which makes it
easy for the end user, but we need to write it.  Also, a web UI for
entering a lot of data can be very cumbersome for users who are used
to Excel/Word/etc.

Second would be a CSV format, that the user can prepare in Excel, and
then uploads it to us.  This has the advantage, that the user can
maybe copy-paste some already existing online data into Excel, format
it to our CSV requirement and then just import it.

# Open questions

User access: in Dreischeibe there are multiple users.  Do we have to
represent in the data model per-user access for the data?  So can it
happen, that different users should see different route data?  Or is
route data a global truth that everyone can enjoy in its full?  (The
train tracks are of course a global truth, but we also have manual
entry, and maybe there are licensing restrictions with the SBB data,
that's why I'm asking.)

Version control of data: SBB releases new versions of the data from
time to time, if we implement manual entry, that will also have newer
versions (with more routes, or fixing previous bugs in the previous
manual entry).  The question is: do we have to represent these
versions in the data model?  There are also cases, when previously
existing track data REALLY changes, not because of bug fixing, but
because of real change in the world: e.g. a new tunnel is built and
that makes a travel distance shorter.  So my guess is that we need
version control in the data model.

Both of these questions (user access, versioned data) is something
that I'm sure other parts of the system already implement.  How do you
guys handle these issues in Dreischeibe, can you propose changes to
the data model to solve these requirements, or should we come up with
something?
