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
DROP INDEX public.priceindex;
DROP INDEX public.paysissuerindex;
DROP INDEX public.ledgersbyseq;
DROP INDEX public.getsissuerindex;
DROP INDEX public.accountlines;
DROP INDEX public.accountbalances;
ALTER TABLE ONLY public.txhistory DROP CONSTRAINT txhistory_pkey;
ALTER TABLE ONLY public.txhistory DROP CONSTRAINT txhistory_ledgerseq_txindex_key;
ALTER TABLE ONLY public.trustlines DROP CONSTRAINT trustlines_pkey;
ALTER TABLE ONLY public.storestate DROP CONSTRAINT storestate_pkey;
ALTER TABLE ONLY public.signers DROP CONSTRAINT signers_pkey;
ALTER TABLE ONLY public.peers DROP CONSTRAINT peers_pkey;
ALTER TABLE ONLY public.offers DROP CONSTRAINT offers_pkey;
ALTER TABLE ONLY public.ledgerheaders DROP CONSTRAINT ledgerheaders_pkey;
ALTER TABLE ONLY public.ledgerheaders DROP CONSTRAINT ledgerheaders_ledgerseq_key;
ALTER TABLE ONLY public.accounts DROP CONSTRAINT accounts_pkey;
DROP TABLE public.txhistory;
DROP TABLE public.trustlines;
DROP TABLE public.storestate;
DROP TABLE public.signers;
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
    accountid character varying(51) NOT NULL,
    balance bigint NOT NULL,
    seqnum bigint NOT NULL,
    numsubentries integer NOT NULL,
    inflationdest character varying(51),
    homedomain character varying(32),
    thresholds text,
    flags integer NOT NULL,
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
    accountid character varying(51) NOT NULL,
    offerid bigint NOT NULL,
    paysalphanumcurrency character varying(4),
    paysissuer character varying(51),
    getsalphanumcurrency character varying(4),
    getsissuer character varying(51),
    amount bigint NOT NULL,
    pricen integer NOT NULL,
    priced integer NOT NULL,
    price bigint NOT NULL,
    flags integer NOT NULL,
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
    rank integer DEFAULT 0 NOT NULL,
    CONSTRAINT peers_numfailures_check CHECK ((numfailures >= 0)),
    CONSTRAINT peers_port_check CHECK (((port > 0) AND (port <= 65535))),
    CONSTRAINT peers_rank_check CHECK ((rank >= 0))
);


--
-- Name: signers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE signers (
    accountid character varying(51) NOT NULL,
    publickey character varying(51) NOT NULL,
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
    accountid character varying(51) NOT NULL,
    issuer character varying(51) NOT NULL,
    alphanumcurrency character varying(4) NOT NULL,
    tlimit bigint DEFAULT 0 NOT NULL,
    balance bigint DEFAULT 0 NOT NULL,
    flags integer NOT NULL,
    CONSTRAINT trustlines_balance_check CHECK ((balance >= 0)),
    CONSTRAINT trustlines_tlimit_check CHECK ((tlimit >= 0))
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

COPY accounts (accountid, balance, seqnum, numsubentries, inflationdest, homedomain, thresholds, flags) FROM stdin;
gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	99999979999999980	2	0	\N		01000000	0
gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	10000000000	12884901888	0	\N		01000000	0
gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	9999999930	12884901895	0	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	nullstyle.com	02000202	0
\.


--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY ledgerheaders (ledgerhash, prevhash, bucketlisthash, ledgerseq, closetime, data) FROM stdin;
a9d12414d405652b752ce4425d3d94e7996a07a52228a58d7bf3bd35dd50eb46	0000000000000000000000000000000000000000000000000000000000000000	e71064e28d0740ac27cf07b267200ea9b8916ad1242195c015fa3012086588d3	1	0	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA5xBk4o0HQKwnzweyZyAOqbiRatEkIZXAFfowEghliNMAAAABAAAAAAAAAAABY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
571b549adcb01db1d32b24527661e4813c1eca4c13657c7e0dd2859cac29d704	a9d12414d405652b752ce4425d3d94e7996a07a52228a58d7bf3bd35dd50eb46	24128cf784e4c94f58a5a72a5036a54e82b2e37c1b1b327bd8af8ab48684abf6	2	1433892090	qdEkFNQFZSt1LORCXT2U55lqB6UiKKWNe/O9Nd1Q60bWGQFaFjFEkPZuQGDTJ8o1Qnt8FuQMpJZu40ekvFPjPOOwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVJBKM94TkyU9YpacqUDalToKy43wbGzJ72K+KtIaEq/YAAAACAAAAAFV3dPoBY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
7421a5d73b2ef9f90a8c0b1ab3cd4ef99193662a71db8e2d7f1015bdcacaf28a	571b549adcb01db1d32b24527661e4813c1eca4c13657c7e0dd2859cac29d704	a99c64a2d3715dd006f1dc72c35fe594517bde0dadf001c7d22c9c52b28d0dba	3	1433892091	VxtUmtywHbHTKyRSdmHkgTweykwTZXx+DdKFnKwp1wTrXutydo2Oyvs6kFjzaT0C3LwMnBp0xrQAVYAT2JwmEZPiilsf0FGBJoAcQNG0NDm3fUpThAO0NLkqsYLarif3qZxkotNxXdAG8dxyw1/llFF73g2t8AHH0iycUrKNDboAAAADAAAAAFV3dPsBY0V4XYoAAAAAAAAAAAAUAAAAAAAAAAAAAAAAAAAACgCYloAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
c512c75f75bc56a910f883f08c11cf1465d89f6866de17ed6c2685b618e2bd83	7421a5d73b2ef9f90a8c0b1ab3cd4ef99193662a71db8e2d7f1015bdcacaf28a	a1ec63370f27cd804bd2ba07aacc131e4bdb07147f35cce75dd2ec976bfafad9	4	1433892092	dCGl1zsu+fkKjAsas81O+ZGTZipx244tfxAVvcrK8ooBoDLN4XMXr67LxZYo0FRS0JR7RPEuwZzkeQCSzi/obdM/yCx6hHmeqmF/9ih3jI2VDCEKo35TNPw6zrxH0hTOoexjNw8nzYBL0roHqswTHkvbBxR/NcznXdLsl2v6+tkAAAAEAAAAAFV3dPwBY0V4XYoAAAAAAAAAAABGAAAAAAAAAAAAAAAAAAAACgCYloAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
d29253d63216390cd5821f3ba56d92961fd938a19c13bb5d0dbf1d313ee6be45	c512c75f75bc56a910f883f08c11cf1465d89f6866de17ed6c2685b618e2bd83	9ca3df411756a27b028a588f35ff21956398ad515fb6f105afd63a68884634ce	5	1433892093	xRLHX3W8VqkQ+IPwjBHPFGXYn2hm3hftbCaFthjivYNuVOwpWTPrJ9o522JNRlLNQi0Q67XLHfOstC+LW+Bhb16XhaNBFzuHnJ4VEzA5NTgoe7NypgcqQ+RWPUvBsQHwnKPfQRdWonsCiliPNf8hlWOYrVFftvEFr9Y6aIhGNM4AAAAFAAAAAFV3dP0BY0V4XYoAAAAAAAAAAABaAAAAAAAAAAAAAAAAAAAACgCYloAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
\.


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY offers (accountid, offerid, paysalphanumcurrency, paysissuer, getsalphanumcurrency, getsissuer, amount, pricen, priced, price, flags) FROM stdin;
\.


--
-- Data for Name: peers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY peers (ip, port, nextattempt, numfailures, rank) FROM stdin;
\.


--
-- Data for Name: signers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY signers (accountid, publickey, weight) FROM stdin;
gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	1
\.


--
-- Data for Name: storestate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY storestate (statename, state) FROM stdin;
databaseinitialized             	true
forcescponnextlaunch            	false
lastclosedledger                	d29253d63216390cd5821f3ba56d92961fd938a19c13bb5d0dbf1d313ee6be45
historyarchivestate             	{\n    "version": 0,\n    "currentLedger": 5,\n    "currentBuckets": [\n        {\n            "curr": "c4239e9bbb180c3641cd9dff52b386f362accec31f80dcec4d0bc2cdaeca5801",\n            "next": {\n                "state": 0\n            },\n            "snap": "7141de76141f231422b5358afaccc618fda153de4d8386751346158f969674db"\n        },\n        {\n            "curr": "dbbd826d458ade51d4a8cfc70260528fb788d3eb80c9a73e49a4cbba1a8f566c",\n            "next": {\n                "state": 1,\n                "output": "7141de76141f231422b5358afaccc618fda153de4d8386751346158f969674db"\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        }\n    ]\n}
\.


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY trustlines (accountid, issuer, alphanumcurrency, tlimit, balance, flags) FROM stdin;
\.


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY txhistory (txid, ledgerseq, txindex, txbody, txresult, txmeta) FROM stdin;
cae6912408e3552ac1653fdacd73aee0b063258b1ea90ed194aecdbdd224c684	3	1	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL5AAAAAABiZsoQAkPQE/vM9msNNOzIMULKVXSalttRpPImBH7bpNz74ZxndhRqOWuIVZSSAvxRab1nFgpcsznFSHxCMiKpJnv/gM=	yuaRJAjjVSrBZT/azXOu4LBjJYseqQ7RlK7NvdIkxoQAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvkAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAACJmyhA7VY2xW3cXxSyOXX3nxuiOI0mlOTFbs3dyWDl7wFjRXYJfhv2AAAAAAAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA=
a47e33a4d8f868fa1fdb91028cd98b7c3e58093807928c94a74a5fc317a2c802	3	2	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAIAAAAAAAAAAAAAAAEAAAAAAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAlQL5AAAAAABiZsoQLodlJo+YEzWjUYeRC6kNMqpGyRiAleVmhDZbuRZQm6Mu+CUlsW9Wibihm6qr1YwjfoldgrS4XSm/ioi3I7DLgk=	pH4zpNj4aPof25ECjNmLfD5YCTgHkoyUp0pfwxeiyAIAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAACVAvkAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAACJmyhA7VY2xW3cXxSyOXX3nxuiOI0mlOTFbs3dyWDl7wFjRXO1cjfsAAAAAAAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA=
a780133c075551625607420364d8212fb666067fba11513f22e2d79bd5f1d283	4	1	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAEAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAE7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAEAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAABrqN6LamHS/IDIG9zlA+sCNf5depDozDzPX1GesBx4kSVQwLlxkjCHxjI/+97fIDWu7l9LUlGemgOwP0D+1+Ex0kmQwM=	p4ATPAdVUWJWB0IDZNghL7ZmBn+6EVE/IuLXm9Xx0oMAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvj9gAAAAMAAAABAAAAAAAAAAE7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAABAAAAAAAAAAAAAAA=
7a22ebabb4febc34711134ee0324081b3dbc7eaf74c8461f030d5fff3d64db43	4	2	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAIAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAAAAAABAAAAAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAa6jei1zF81GRFEaVIqCGb4CWyyOiXp45mQyyaiyJhpRGDBC4lX2Ky1dtAwz5lwoz5LkU1UhJV7P5dGFuxVZNyXB04cP	eiLrq7T+vDRxETTuAyQIGz28fq90yEYfAw1f/z1k20MAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvj7AAAAAMAAAACAAAAAAAAAAE7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAEBAAAAAAAAAAAAAAA=
c9af16fd56ceed9eda61b5c29cc6bad229f75ed8f6626f7d918863f543a08f78	4	3	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAMAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAQIAAgIAAAAAAAAAAAAAAAGuo3otpjxglW+hXJAh3UzfDGg12lRa5OBjkaZTwqURj8mq/uo9z7D/38uoVNH3pLhQLaTqu8jzbAw2qwA7pn1yRw2NBA==	ya8W/VbO7Z7aYbXCnMa60in3Xtj2Ym99kYhj9UOgj3gAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvj4gAAAAMAAAADAAAAAAAAAAE7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAECAAICAAAAAAAAAAA=
3df957cc1d7d8b96c5b4527d6f847d47992e830e763b729d982b1c174b65234d	4	4	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAQAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAANbnVsbHN0eWxlLmNvbQAAAAAAAAAAAAABrqN6LUZJJcS3rzDdDykTh1rP+OsFZ4syaFlSUqeiAiHogqMIPYFTJorquFY+lXjtQWYlYluYEGZnbDAeIGYbfUUz8wA=	PflXzB19i5bFtFJ9b4R9R5kugw52O3KdmCscF0tlI00AAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvj2AAAAAMAAAAEAAAAAAAAAAE7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAECAAICAAAADW51bGxzdHlsZS5jb20AAAAAAAAA
a917a16f5818014ed2136913925eedd0052e77a2e02926e98a41e815fa5420eb	4	5	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAUAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAABAAAAAa6jei0j+Wj6dszEJeQGAKlM6jBVmZeevD3zsM36vLyY5+p0XEcnEkWOS8TiYIbCUNiJehP1qPSMxhON+j1z8y5zcB8L	qRehb1gYAU7SE2kTkl7t0AUud6LgKSbpikHoFfpUIOsAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjzgAAAAMAAAAFAAAAAQAAAAE7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAECAAICAAAADW51bGxzdHlsZS5jb20AAAAAAAABtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAB
c7f97ca81f1d072e9b6be79eb0d09c6dbf2762c08a11877b338846bb9b50d2ae	5	1	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAYAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAAAAAABAAAAAQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAa6jei0OAND+ctg1MNHcLSGs3VHf/4t+wLHnPcltPzhTkHpcDQxXvmJfhwhJ198pl1rnRSHKIQ1sHB8gjJNIJt0F2IQB	x/l8qB8dBy6ba+eesNCcbb8nYsCKEYd7M4hGu5tQ0q4AAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjxAAAAAMAAAAGAAAAAQAAAAE7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAACAAICAAAADW51bGxzdHlsZS5jb20AAAAAAAABtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAB
f263ff72eb0c52ec5bf5f994f846cad2309198efbf9934dc985dfae0ce2ebe28	5	2	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAcAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAa6jei2mnC6rrQgGZFISt9wl3Dl5SH+i41X9du/D1TqAZS6kGC1dUVQnWbqh+EoUU8LKkKrVPit+MULoL80EAQFzITAJ	8mP/cusMUuxb9fmU+EbK0jCRmO+/mTTcmF364M4uvigAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjugAAAAMAAAAHAAAAAAAAAAE7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAACAAICAAAADW51bGxzdHlsZS5jb20AAAAAAAAA
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
    ADD CONSTRAINT trustlines_pkey PRIMARY KEY (accountid, issuer, alphanumcurrency);


--
-- Name: txhistory_ledgerseq_txindex_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY txhistory
    ADD CONSTRAINT txhistory_ledgerseq_txindex_key UNIQUE (ledgerseq, txindex);


--
-- Name: txhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY txhistory
    ADD CONSTRAINT txhistory_pkey PRIMARY KEY (txid, ledgerseq);


--
-- Name: accountbalances; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX accountbalances ON accounts USING btree (balance);


--
-- Name: accountlines; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX accountlines ON trustlines USING btree (accountid);


--
-- Name: getsissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX getsissuerindex ON offers USING btree (getsissuer);


--
-- Name: ledgersbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ledgersbyseq ON ledgerheaders USING btree (ledgerseq);


--
-- Name: paysissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX paysissuerindex ON offers USING btree (paysissuer);


--
-- Name: priceindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX priceindex ON offers USING btree (price);


--
-- Name: signersaccount; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX signersaccount ON signers USING btree (accountid);


--
-- PostgreSQL database dump complete
--

