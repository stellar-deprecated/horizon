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

DROP INDEX public.ledgersbyseq;
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
    paysisocurrency character varying(4) NOT NULL,
    paysissuer character varying(51) NOT NULL,
    getsisocurrency character varying(4) NOT NULL,
    getsissuer character varying(51) NOT NULL,
    amount bigint NOT NULL,
    pricen integer NOT NULL,
    priced integer NOT NULL,
    price bigint NOT NULL,
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
    isocurrency character varying(4) NOT NULL,
    tlimit bigint DEFAULT 0 NOT NULL,
    balance bigint DEFAULT 0 NOT NULL,
    authorized boolean NOT NULL,
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

COPY accounts (accountid, balance, seqnum, numsubentries, inflationdest, thresholds, flags) FROM stdin;
gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	99999996999999970	3	0	\N	01000000	0
gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	999999990	12884901889	1	\N	01000000	0
gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	999999990	12884901889	0	\N	01000000	0
gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	999999980	12884901890	1	\N	01000000	0
\.


--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY ledgerheaders (ledgerhash, prevhash, bucketlisthash, ledgerseq, closetime, data) FROM stdin;
43cf4db3741a7d6c2322e7b646320ce9d7b099a0b3501734dcf70e74a8a4e637	0000000000000000000000000000000000000000000000000000000000000000	e34f893566871dadaab7fdbb9fe111aac7ac542417271f9f3fd891b963264d1d	1	0	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA40+JNWaHHa2qt/27n+ERqsesVCQXJx+fP9iRuWMmTR0AAAABAAAAAAAAAAABY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloA=
d74bea932a00fb300e769f2662628c5e33b297855e3708ed41698ee1c1e979a5	43cf4db3741a7d6c2322e7b646320ce9d7b099a0b3501734dcf70e74a8a4e637	1831262bef6a1962aaa245f4000edd3000c503fe282864f740777f4d74acbfc4	2	1430519911	Q89Ns3QafWwjIue2RjIM6dewmaCzUBc03PcOdKik5jf5KRx0BucwVFzutse7JWwEx/lTgjuFE8q7isUyUGec6eOwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVGDEmK+9qGWKqokX0AA7dMADFA/4oKGT3QHd/TXSsv8QAAAACAAAAAFVEAGcBY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloA=
20e007c7427e3bea3ca048e078c68a4c160f3d42139fa4162c07544cc13a2bdb	d74bea932a00fb300e769f2662628c5e33b297855e3708ed41698ee1c1e979a5	8269512bd4233eda0898d4bab1231b8821228944a2fb817f10359e62b9174897	3	1430519912	10vqkyoA+zAOdp8mYmKMXjOyl4VeNwjtQWmO4cHpeaUDQbZbmNSxYrGta+1pNw5ykCBAb4Yhcgm5Mb+7lWDdhuriFgtwbYcxteiuSFplxifgzqleGiGk5M43MqZm5wqogmlRK9QjPtoImNS6sSMbiCEiiUSi+4F/EDWeYrkXSJcAAAADAAAAAFVEAGgBY0V4XYoAAAAAAAAAAAAeAAAAAAAAAAAAAAAAAAAACgCYloA=
4f0ab6663d0e3a22d469b75c884f218f2ded1d8b7d627dff3599a054d47d3124	20e007c7427e3bea3ca048e078c68a4c160f3d42139fa4162c07544cc13a2bdb	2997262e7e46f531b0fb35329c759ce26b52725d4723afb8adafb5eb99dfc270	4	1430519913	IOAHx0J+O+o8oEjgeMaKTBYPPUITn6QWLAdUTME6K9s9e3sYbdK4dZa95BBJONmwtOVRyU2dkn1FlFjyHJv2I2GS/vXD40eVrRpXSUJzA1A1f3xHRG6ZjbsPsJIOezOmKZcmLn5G9TGw+zUynHWc4mtScl1HI6+4ra+165nfwnAAAAAEAAAAAFVEAGkBY0V4XYoAAAAAAAAAAAAyAAAAAAAAAAAAAAAAAAAACgCYloA=
e904e3b9e82062803caf326976d6597b079b83e18ddc0f624dbbc09b64b1cedd	4f0ab6663d0e3a22d469b75c884f218f2ded1d8b7d627dff3599a054d47d3124	397a6643ee815ade3e32ca0fd143bb59b02bced50cba9442a25eaac52dc32404	5	1430519914	Twq2Zj0OOiLUabdciE8hjy3tHYt9Yn3/NZmgVNR9MSR72UZ14swWuX5d/E8N57LMxreBd3+Ot68YSEjTus8P+t2nGdsqlvjZ97QW2U6XFTQrbv4pVqdw6WeY0rBJ0t4kOXpmQ+6BWt4+MsoP0UO7WbArztUMupRCol6qxS3DJAQAAAAFAAAAAFVEAGoBY0V4XYoAAAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAACgCYloA=
8dbc3ef6ac2a6748c126302da3b83ce50cabcf5afebf45936817e3f876224451	e904e3b9e82062803caf326976d6597b079b83e18ddc0f624dbbc09b64b1cedd	1f7237b7a42602c3694ca6773bf26ffa35a928c98a026ea22f1f08ef121aba70	6	1430519915	6QTjueggYoA8rzJpdtZZewebg+GN3A9iTbvAm2Sxzt3UovFNhgfOP87nK5aQwYJq8p/Pkmb7QwpObrmj/jhylMlTXTZ4Vv7w+/ewuO7hM0cEBLmrsX/VlO2fzi+DlOmtH3I3t6QmAsNpTKZ3O/Jv+jWpKMmKAm6iLx8I7xIaunAAAAAGAAAAAFVEAGsBY0V4XYoAAAAAAAAAAABGAAAAAAAAAAAAAAAAAAAACgCYloA=
\.


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY offers (accountid, offerid, paysisocurrency, paysissuer, getsisocurrency, getsissuer, amount, pricen, priced, price) FROM stdin;
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
\.


--
-- Data for Name: storestate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY storestate (statename, state) FROM stdin;
databaseInitialized             	true
forceSCPOnNextLaunch            	false
lastClosedLedger                	8dbc3ef6ac2a6748c126302da3b83ce50cabcf5afebf45936817e3f876224451
historyArchiveState             	{\n    "version": 0,\n    "currentLedger": 6,\n    "currentBuckets": [\n        {\n            "curr": "020fceaec5824b9a4fc55ebd32daef3aac91ed0d9d71c55f40c671aeeea17a29",\n            "next": {\n                "state": 0\n            },\n            "snap": "024dbb6b6f513faf6e8d44c2473edd76334789c8787920a955e74251c77f7af0"\n        },\n        {\n            "curr": "18c37becbfa3350dfdc61fe84f271e9f265e8517253b7b42b26fd58e8324abed",\n            "next": {\n                "state": 1,\n                "output": "024dbb6b6f513faf6e8d44c2473edd76334789c8787920a955e74251c77f7af0"\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        }\n    ]\n}
\.


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY trustlines (accountid, issuer, isocurrency, tlimit, balance, authorized) FROM stdin;
gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	USD	9223372036854775807	500000000	t
gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	USD	9223372036854775807	500000000	t
\.


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY txhistory (txid, ledgerseq, txindex, txbody, txresult, txmeta) FROM stdin;
5f4757783fe158dce8fc1571cc66482b7bcb79487fce6b7c55b68d8154dd24bb	3	1	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAEAAAAA/////wAAAAEAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAAAAAAA7msoAAAAAAAAAAAAAAAAAAAAAADuaygAAAAABiZsoQNHxNzc6+PR2G/FrvVDMDMZPNEgpLo+CUwsj3/gw9ZOk5zQdPtMZmhFz7RB//536YjTgACcXSrIgYGiW/bKNlAA=	X0dXeD/hWNzo/BVxzGZIK3vLeUh/zmt8VbaNgVTdJLsAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAO5rKAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAImbKEDtVjbFbdxfFLI5dfefG6I4jSaU5MVuzd3JYOXvAWNFeCHvNfYAAAAAAAAAAQAAAAAAAAAAAAAAAAEAAAAAAAAA
1f4426e221f3ef7271c0d84940512cae677dfd01c7049d6a6f675496258e13e2	3	2	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAIAAAAA/////wAAAAEAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAA7msoAAAAAAAAAAAAAAAAAAAAAADuaygAAAAABiZsoQIfvpK5OqM3xS+k+70UdrSGb+vxAJuhxU9NEzNOnqoPWxJTtY63Zfk9x7udyhqB0LnHJom5MBgmr7vR+RtVVFgw=	H0Qm4iHz73JxwNhJQFEsrmd9/QHHBJ1qb2dUliWOE+IAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAImbKEDtVjbFbdxfFLI5dfefG6I4jSaU5MVuzd3JYOXvAWNFd+ZUa+wAAAAAAAAAAgAAAAAAAAAAAAAAAAEAAAAAAAAA
774e2ce667a8c4070f4d43e8f74ec86f549cee6344dfe582877be72859586a8e	3	3	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAMAAAAA/////wAAAAEAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAAAAAAA7msoAAAAAAAAAAAAAAAAAAAAAADuaygAAAAABiZsoQBUO5K/IbcVtqv6hmAWw0eOmkfQoI19FxQAKRfTxDqVH6i+oTaLcDVEUz28qLBjNVuGhmG8nkZjIg6zGsvU2uwg=	d04s5meoxAcPTUPo907Ib1Sc7mNE3+WCh3vnKFlYao4AAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAAAO5rKAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAImbKEDtVjbFbdxfFLI5dfefG6I4jSaU5MVuzd3JYOXvAWNFd6q5oeIAAAAAAAAAAwAAAAAAAAAAAAAAAAEAAAAAAAAA
27461f6a0de4b4ae089d500ac5719552620c27c4c4f7c87a197a1b315bfd405c	4	1	bmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAAKAAAAAwAAAAEAAAAA/////wAAAAEAAAAAAAAAAwAAAAFVU0QAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe9//////////wAAAAFuaCbVoSLVbvTd1L8LfxgEVcEvmyUoF5SW2+gs8V4EAHbDMr7AzzL7OaqPWrAOOthr4zkyeeCd2bcMasggELgHJnIJCg==	J0Yfag3ktK4InVAKxXGVUmIMJ8TE98h6GXobMVv9QFwAAAAAAAAACgAAAAAAAAABAAAAAAAAAAMAAAAA	AAAAAgAAAAAAAAABbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAABVVNEALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAAAAAAB//////////wAAAAEAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAADuayfYAAAADAAAAAQAAAAEAAAAAAAAAAAEAAAAAAAAA
e8f2c211b668b4ce6ac7634ff4989e0cba1f260e74af34bae558be3a3cb2c4a1	4	2	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAEAAAAA/////wAAAAEAAAAAAAAAAwAAAAFVU0QAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe9//////////wAAAAGuo3otOOpa5cOouWMq+R2OhwGAWPiIsfga83b2iryaXeOmUa29KV0chli+neQjBs5arcvYzrCCW9YroOpHlbwZ2iB6AQ==	6PLCEbZotM5qx2NP9JieDLofJg50rzS65Vi+OjyyxKEAAAAAAAAACgAAAAAAAAABAAAAAAAAAAMAAAAA	AAAAAgAAAAAAAAABrqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAABVVNEALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAAAAAAB//////////wAAAAEAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAADuayfYAAAADAAAAAQAAAAEAAAAAAAAAAAEAAAAAAAAA
fce5df0163ac62c8bbc8afc83f0aa1c0bdc13c9fbfb600117bd0db81db9cb91d	5	1	tbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAKAAAAAwAAAAEAAAAA/////wAAAAEAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAA7msoAAAAAAAAAAAAAAAAAAAAAADuaygAAAAABtbgXR+gtjU4ENRi2hRIj9AXl9eq+/ja/NVmGddxIah70AJK7g9hmR6c9mJ6xt8PwTXwd8nQ0ygPSzChQa5Xy9PYvBgk=	/OXfAWOsYsi7yK/IPwqhwL3BPJ+/tgARe9DbgducuR0AAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAO5rJ9gAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAa6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAA7msoAf/////////8AAAAB
67f7b0fade18c707bb95082b8abdbdf9881e4e44b7d83be54c807682db948f97	6	1	rqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAKAAAAAwAAAAIAAAAA/////wAAAAEAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAAdzWUAAAAAAAAAAAAAAAAAAAAAAB3NZQAAAAABrqN6LQHJ7TONyTbCbrQY01z/CcL95821la91o1jQGBqo0l/LS4js2/dKHV8brhQolHZ54Y84U7XAWTsyLWAHLqwa1go=	Z/ew+t4Yxwe7lQgrir29+YgeTkS32DvlTIB2gtuUj5cAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAwAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rJ7AAAAAMAAAACAAAAAQAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAW5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAAdzWUAf/////////8AAAABAAAAAAAAAAGuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAFVU0QAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAHc1lAH//////////AAAAAQ==
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
    ADD CONSTRAINT trustlines_pkey PRIMARY KEY (accountid, issuer, isocurrency);


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
-- Name: ledgersbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ledgersbyseq ON ledgerheaders USING btree (ledgerseq);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM nullstyle;
GRANT ALL ON SCHEMA public TO nullstyle;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

