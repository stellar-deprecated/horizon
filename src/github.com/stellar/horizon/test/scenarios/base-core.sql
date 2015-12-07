--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX public.signersaccount;
DROP INDEX public.sellingissuerindex;
DROP INDEX public.scpenvsbyseq;
DROP INDEX public.priceindex;
DROP INDEX public.ledgersbyseq;
DROP INDEX public.histfeebyseq;
DROP INDEX public.histbyseq;
DROP INDEX public.buyingissuerindex;
DROP INDEX public.accountbalances;
ALTER TABLE ONLY public.txhistory DROP CONSTRAINT txhistory_pkey;
ALTER TABLE ONLY public.txfeehistory DROP CONSTRAINT txfeehistory_pkey;
ALTER TABLE ONLY public.trustlines DROP CONSTRAINT trustlines_pkey;
ALTER TABLE ONLY public.storestate DROP CONSTRAINT storestate_pkey;
ALTER TABLE ONLY public.signers DROP CONSTRAINT signers_pkey;
ALTER TABLE ONLY public.scpquorums DROP CONSTRAINT scpquorums_pkey;
ALTER TABLE ONLY public.pubsub DROP CONSTRAINT pubsub_pkey;
ALTER TABLE ONLY public.publishqueue DROP CONSTRAINT publishqueue_pkey;
ALTER TABLE ONLY public.peers DROP CONSTRAINT peers_pkey;
ALTER TABLE ONLY public.offers DROP CONSTRAINT offers_pkey;
ALTER TABLE ONLY public.ledgerheaders DROP CONSTRAINT ledgerheaders_pkey;
ALTER TABLE ONLY public.ledgerheaders DROP CONSTRAINT ledgerheaders_ledgerseq_key;
ALTER TABLE ONLY public.accounts DROP CONSTRAINT accounts_pkey;
DROP TABLE public.txhistory;
DROP TABLE public.txfeehistory;
DROP TABLE public.trustlines;
DROP TABLE public.storestate;
DROP TABLE public.signers;
DROP TABLE public.scpquorums;
DROP TABLE public.scphistory;
DROP TABLE public.pubsub;
DROP TABLE public.publishqueue;
DROP TABLE public.peers;
DROP TABLE public.offers;
DROP TABLE public.ledgerheaders;
DROP TABLE public.accounts;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    accountid character varying(56) NOT NULL,
    balance bigint NOT NULL,
    seqnum bigint NOT NULL,
    numsubentries integer NOT NULL,
    inflationdest character varying(56),
    homedomain character varying(32) NOT NULL,
    thresholds text NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT accounts_balance_check CHECK ((balance >= 0)),
    CONSTRAINT accounts_numsubentries_check CHECK ((numsubentries >= 0))
);


--
-- Name: ledgerheaders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ledgerheaders (
    ledgerhash character(64) NOT NULL,
    prevhash character(64) NOT NULL,
    bucketlisthash character(64) NOT NULL,
    ledgerseq integer,
    closetime bigint NOT NULL,
    data text NOT NULL,
    CONSTRAINT ledgerheaders_closetime_check CHECK ((closetime >= 0)),
    CONSTRAINT ledgerheaders_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: offers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE offers (
    sellerid character varying(56) NOT NULL,
    offerid bigint NOT NULL,
    sellingassettype integer NOT NULL,
    sellingassetcode character varying(12),
    sellingissuer character varying(56),
    buyingassettype integer NOT NULL,
    buyingassetcode character varying(12),
    buyingissuer character varying(56),
    amount bigint NOT NULL,
    pricen integer NOT NULL,
    priced integer NOT NULL,
    price double precision NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT offers_amount_check CHECK ((amount >= 0)),
    CONSTRAINT offers_offerid_check CHECK ((offerid >= 0))
);


--
-- Name: peers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE peers (
    ip character varying(15) NOT NULL,
    port integer DEFAULT 0 NOT NULL,
    nextattempt timestamp without time zone NOT NULL,
    numfailures integer DEFAULT 0 NOT NULL,
    CONSTRAINT peers_numfailures_check CHECK ((numfailures >= 0)),
    CONSTRAINT peers_port_check CHECK (((port > 0) AND (port <= 65535)))
);


--
-- Name: publishqueue; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE publishqueue (
    ledger integer NOT NULL,
    state text
);


--
-- Name: pubsub; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pubsub (
    resid character(32) NOT NULL,
    lastread integer
);


--
-- Name: scphistory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scphistory (
    nodeid character(56) NOT NULL,
    ledgerseq integer NOT NULL,
    envelope text NOT NULL,
    CONSTRAINT scphistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: scpquorums; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scpquorums (
    qsethash character(64) NOT NULL,
    lastledgerseq integer NOT NULL,
    qset text NOT NULL,
    CONSTRAINT scpquorums_lastledgerseq_check CHECK ((lastledgerseq >= 0))
);


--
-- Name: signers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE signers (
    accountid character varying(56) NOT NULL,
    publickey character varying(56) NOT NULL,
    weight integer NOT NULL
);


--
-- Name: storestate; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE storestate (
    statename character(32) NOT NULL,
    state text
);


--
-- Name: trustlines; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trustlines (
    accountid character varying(56) NOT NULL,
    assettype integer NOT NULL,
    issuer character varying(56) NOT NULL,
    assetcode character varying(12) NOT NULL,
    tlimit bigint NOT NULL,
    balance bigint NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT trustlines_balance_check CHECK ((balance >= 0)),
    CONSTRAINT trustlines_tlimit_check CHECK ((tlimit > 0))
);


--
-- Name: txfeehistory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE txfeehistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txchanges text NOT NULL,
    CONSTRAINT txfeehistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: txhistory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE txhistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txbody text NOT NULL,
    txresult text NOT NULL,
    txmeta text NOT NULL,
    CONSTRAINT txhistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY accounts (accountid, balance, seqnum, numsubentries, inflationdest, homedomain, thresholds, flags, lastmodified) FROM stdin;
GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2	1000000000	8589934592	0	\N		AQAAAA==	0	2
GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	999999996999999700	3	0	\N		AQAAAA==	0	2
GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON	1050000000	8589934592	0	\N		AQAAAA==	0	3
GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	949999900	8589934593	0	\N		AQAAAA==	0	3
\.


--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY ledgerheaders (ledgerhash, prevhash, bucketlisthash, ledgerseq, closetime, data) FROM stdin;
63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99	0000000000000000000000000000000000000000000000000000000000000000	572a2e32ff248a07b0e70fd1f6d318c1facd20b6cc08c33d5775259868125a16	1	0	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABXKi4y/ySKB7DnD9H20xjB+s0gtswIwz1XdSWYaBJaFgAAAAEN4Lazp2QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZAX14QAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
461183255c91d24277787ed54b9eb55c40f0e32200518fac22b18bb2e5985965	63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99	8eb63d15a9e8c24469fc0382b02678bb9ea79abbfd04861fc693cc840e6ee71e	2	1449523517	AAAAAWPZj1Nu5o0bJ7W4nyOvUxG3Vpok+vFAOtC1K2M7B76ZlmEdOpVCM5HLr9FNj55qa6w2HKMtqTPFLvG8yPU/aAoAAAAAVmX5PQAAAAIAAAAIAAAAAQAAAAEAAAAIAAAAAwAAADIAAAAARUAVxJm1lDMwwqujKcyQzs97F/AETiCgQPrw63wqaPGOtj0VqejCRGn8A4KwJni7nqeau/0Ehh/Gk8yEDm7nHgAAAAIN4Lazp2QAAAAAAAAAAAEsAAAAAAAAAAAAAAAAAAAAZAX14QAAAAAyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
bdbba688a85d6caa526ab6f74cdfd3f8644f9c18b4556bad6984207425bae1f0	461183255c91d24277787ed54b9eb55c40f0e32200518fac22b18bb2e5985965	205d6ca1f76a7635564b509b3df0b5db6571ebb66c04366b1930473c99992ae8	3	1449523518	AAAAAUYRgyVckdJCd3h+1UuetVxA8OMiAFGPrCKxi7LlmFllvy4n8omMm0b3IO/r+yeOHeIbEHOWXNeiGEaKNcbJZwgAAAAAVmX5PgAAAAAAAAAAFMKJva6QmOlDLtejYbhpYI7SUKOfeJbIdkqj9wO1AtogXWyh92p2NVZLUJs98LXbZXHrtmwENmsZMEc8mZkq6AAAAAMN4Lazp2QAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAZAX14QAAAAAyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
\.


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY offers (sellerid, offerid, sellingassettype, sellingassetcode, sellingissuer, buyingassettype, buyingassetcode, buyingissuer, amount, pricen, priced, price, flags, lastmodified) FROM stdin;
\.


--
-- Data for Name: peers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY peers (ip, port, nextattempt, numfailures) FROM stdin;
\.


--
-- Data for Name: publishqueue; Type: TABLE DATA; Schema: public; Owner: -
--

COPY publishqueue (ledger, state) FROM stdin;
\.


--
-- Data for Name: pubsub; Type: TABLE DATA; Schema: public; Owner: -
--

COPY pubsub (resid, lastread) FROM stdin;
\.


--
-- Data for Name: scphistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scphistory (nodeid, ledgerseq, envelope) FROM stdin;
GB5OCN3RQ4JHV42NMJQRNEFFOOPXHR7AINXZYYHLSXVBX3HZRZYLW473	2	AAAAAHrhN3GHEnrzTWJhFpClc59zx+BDb5xg65XqG+z5jnC7AAAAAAAAAAIAAAACAAAAAQAAAEiWYR06lUIzkcuv0U2PnmprrDYcoy2pM8Uu8bzI9T9oCgAAAABWZfk9AAAAAgAAAAgAAAABAAAAAQAAAAgAAAADAAAAMgAAAAAAAAABebIw2H2gD0qa+oOpLf5MdO3oYdixAJ2WXGefyG5JefMAAABAGO/V+4WvjD8DbWTfB41u2un/48PP3ZrglhXc8PKZLYL6dQ5eb0aUwNsowosdp0NtETCnEigAC4e446pkcErZBQ==
GB5OCN3RQ4JHV42NMJQRNEFFOOPXHR7AINXZYYHLSXVBX3HZRZYLW473	3	AAAAAHrhN3GHEnrzTWJhFpClc59zx+BDb5xg65XqG+z5jnC7AAAAAAAAAAMAAAACAAAAAQAAADC/LifyiYybRvcg7+v7J44d4hsQc5Zc16IYRoo1xslnCAAAAABWZfk+AAAAAAAAAAAAAAABebIw2H2gD0qa+oOpLf5MdO3oYdixAJ2WXGefyG5JefMAAABAvTupFluE8rWgS3FR8nUi34+ya58L+Lv4KwYBeCxaibmjuqjlYL7EnIYORmAWVQPYHoviKOIidnB6JHfWXkZ+BQ==
\.


--
-- Data for Name: scpquorums; Type: TABLE DATA; Schema: public; Owner: -
--

COPY scpquorums (qsethash, lastledgerseq, qset) FROM stdin;
79b230d87da00f4a9afa83a92dfe4c74ede861d8b1009d965c679fc86e4979f3	3	AAAAAQAAAAEAAAAAeuE3cYcSevNNYmEWkKVzn3PH4ENvnGDrleob7PmOcLsAAAAA
\.


--
-- Data for Name: signers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY signers (accountid, publickey, weight) FROM stdin;
\.


--
-- Data for Name: storestate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY storestate (statename, state) FROM stdin;
databaseschema                  	2
forcescponnextlaunch            	false
lastclosedledger                	bdbba688a85d6caa526ab6f74cdfd3f8644f9c18b4556bad6984207425bae1f0
historyarchivestate             	{\n    "version": 1,\n    "server": "v0.3.3-7-geed8964",\n    "currentLedger": 3,\n    "currentBuckets": [\n        {\n            "curr": "554613ed35728190bdae94709f59b195fbe9f90bb0841f5de57c15172f90f06a",\n            "next": {\n                "state": 0\n            },\n            "snap": "ef31a20a398ee73ce22275ea8177786bac54656f33dcc4f3fec60d55ddf163d9"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 1,\n                "output": "ef31a20a398ee73ce22275ea8177786bac54656f33dcc4f3fec60d55ddf163d9"\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        }\n    ]\n}
lastscpdata                     	AAAAAgAAAAB64TdxhxJ6801iYRaQpXOfc8fgQ2+cYOuV6hvs+Y5wuwAAAAAAAAADAAAAA3myMNh9oA9KmvqDqS3+THTt6GHYsQCdllxnn8huSXnzAAAAAQAAADC/LifyiYybRvcg7+v7J44d4hsQc5Zc16IYRoo1xslnCAAAAABWZfk+AAAAAAAAAAAAAAABAAAAML8uJ/KJjJtG9yDv6/snjh3iGxBzllzXohhGijXGyWcIAAAAAFZl+T4AAAAAAAAAAAAAAECl7Ho27zKjKtSLOQC1GO8ENojSBf9wAkmZC2cQIK91tEhF+ACO+7oxj96k7hiwDoizeiEKGoOlByIb86zoxPECAAAAAHrhN3GHEnrzTWJhFpClc59zx+BDb5xg65XqG+z5jnC7AAAAAAAAAAMAAAACAAAAAQAAADC/LifyiYybRvcg7+v7J44d4hsQc5Zc16IYRoo1xslnCAAAAABWZfk+AAAAAAAAAAAAAAABebIw2H2gD0qa+oOpLf5MdO3oYdixAJ2WXGefyG5JefMAAABAvTupFluE8rWgS3FR8nUi34+ya58L+Lv4KwYBeCxaibmjuqjlYL7EnIYORmAWVQPYHoviKOIidnB6JHfWXkZ+BQAAAAFGEYMlXJHSQnd4ftVLnrVcQPDjIgBRj6wisYuy5ZhZZQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAABkAAAAAgAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAQAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAAAAAAAAvrwgAAAAAAAAAABruS+TAAAAED0+72mPKRxFLrSWo4uo3wUfPbjhA/xtpg15NMlkiWvdJtELXeoSv24/g5EODIIH+By6DYYqsMy4rRJPdA5opQHAAAAAQAAAAEAAAABAAAAAHrhN3GHEnrzTWJhFpClc59zx+BDb5xg65XqG+z5jnC7AAAAAA==
\.


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY trustlines (accountid, assettype, issuer, assetcode, tlimit, balance, flags, lastmodified) FROM stdin;
\.


--
-- Data for Name: txfeehistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY txfeehistory (txid, ledgerseq, txindex, txchanges) FROM stdin;
2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d	2	1	AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
164a5064eba64f2cdbadb856bf3448485fc626247ada3ed39cddf0f6902133b6	2	2	AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
2b2e82dbabb024b27a0c3140ca71d8ac9bc71831f9f5a3bd69eca3d88fb0ec5c	2	3	AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/7UAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
cebb875a00ff6e1383aef0fd251a76f22c1f9ab2a2dffcb077855736ade2659a	3	1	AAAAAgAAAAMAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msoAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msmcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
\.


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY txhistory (txid, ledgerseq, txindex, txbody, txresult, txmeta) FROM stdin;
2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d	2	1	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAECDzqvkQBQoNAJifPRXDoLhvtycT3lFPCQ51gkdsFHaBNWw05S/VhW0Xgkr0CBPE4NaFV2Kmcs3ZwLmib4TRrML	I3Tpk0m57326ml2zM5t4/ajzR3exrzO6RorVwN+UbU0AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAADuaygAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2s2vJNNQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA
164a5064eba64f2cdbadb856bf3448485fc626247ada3ed39cddf0f6902133b6	2	2	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEASEZiZbeFwCsrKBnKIus/05VtJDBrgosuhLQ/U6XUj4twWyhs7UtS4CMexOM6JqcfqJK10WlBkkwn4g8PIfjIG	FkpQZOumTyzbrbhWvzRISF/GJiR62j7TnN3w9pAhM7YAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAADuaygAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2szAuatQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA
2b2e82dbabb024b27a0c3140ca71d8ac9bc71831f9f5a3bd69eca3d88fb0ec5c	2	3	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEDJul1tLGLF4Vxwt0dDCVEf6tb5l4byMrGgCp+lVZMmxct54iNf2mxtjx6Md5ZJ4E4Dlcsf46EAhBGSUPsn8fYD	Ky6C26uwJLJ6DDFAynHYrJvHGDH59aO9aeyj2I+w7FwAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAADuaygAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2svSToNQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA
cebb875a00ff6e1383aef0fd251a76f22c1f9ab2a2dffcb077855736ade2659a	3	1	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAAAAAAAAAL68IAAAAAAAAAAAa7kvkwAAABA9Pu9pjykcRS60lqOLqN8FHz244QP8baYNeTTJZIlr3SbRC13qEr9uP4ORDgyCB/gcug2GKrDMuK0ST3QOaKUBw==	zruHWgD/bhODrvD9JRp28iwfmrKi3/ywd4VXNq3iZZoAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==	AAAAAAAAAAEAAAADAAAAAwAAAAIAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAADuaygAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAD6VuoAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAADif2RwAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA
\.


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (accountid);


--
-- Name: ledgerheaders_ledgerseq_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ledgerheaders
    ADD CONSTRAINT ledgerheaders_ledgerseq_key UNIQUE (ledgerseq);


--
-- Name: ledgerheaders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ledgerheaders
    ADD CONSTRAINT ledgerheaders_pkey PRIMARY KEY (ledgerhash);


--
-- Name: offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (offerid);


--
-- Name: peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY peers
    ADD CONSTRAINT peers_pkey PRIMARY KEY (ip, port);


--
-- Name: publishqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY publishqueue
    ADD CONSTRAINT publishqueue_pkey PRIMARY KEY (ledger);


--
-- Name: pubsub_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pubsub
    ADD CONSTRAINT pubsub_pkey PRIMARY KEY (resid);


--
-- Name: scpquorums_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scpquorums
    ADD CONSTRAINT scpquorums_pkey PRIMARY KEY (qsethash);


--
-- Name: signers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY signers
    ADD CONSTRAINT signers_pkey PRIMARY KEY (accountid, publickey);


--
-- Name: storestate_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY storestate
    ADD CONSTRAINT storestate_pkey PRIMARY KEY (statename);


--
-- Name: trustlines_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trustlines
    ADD CONSTRAINT trustlines_pkey PRIMARY KEY (accountid, issuer, assetcode);


--
-- Name: txfeehistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY txfeehistory
    ADD CONSTRAINT txfeehistory_pkey PRIMARY KEY (ledgerseq, txindex);


--
-- Name: txhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY txhistory
    ADD CONSTRAINT txhistory_pkey PRIMARY KEY (ledgerseq, txindex);


--
-- Name: accountbalances; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX accountbalances ON accounts USING btree (balance) WHERE (balance >= 1000000000);


--
-- Name: buyingissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX buyingissuerindex ON offers USING btree (buyingissuer);


--
-- Name: histbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX histbyseq ON txhistory USING btree (ledgerseq);


--
-- Name: histfeebyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX histfeebyseq ON txfeehistory USING btree (ledgerseq);


--
-- Name: ledgersbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ledgersbyseq ON ledgerheaders USING btree (ledgerseq);


--
-- Name: priceindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX priceindex ON offers USING btree (price);


--
-- Name: scpenvsbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX scpenvsbyseq ON scphistory USING btree (ledgerseq);


--
-- Name: sellingissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX sellingissuerindex ON offers USING btree (sellingissuer);


--
-- Name: signersaccount; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX signersaccount ON signers USING btree (accountid);


--
-- PostgreSQL database dump complete
--

