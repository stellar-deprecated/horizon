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
gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	99999995999999960	4	0	\N		01000000	0
gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	999999990	12884901889	0	\N		01000000	0
gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	999999990	12884901889	0	\N		01000000	0
gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	999999950	12884901893	5	\N		01000000	0
gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	999999960	12884901892	3	\N		01000000	0
\.


--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY ledgerheaders (ledgerhash, prevhash, bucketlisthash, ledgerseq, closetime, data) FROM stdin;
41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	0000000000000000000000000000000000000000000000000000000000000000	e71064e28d0740ac27cf07b267200ea9b8916ad1242195c015fa3012086588d3	1	0	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA5xBk4o0HQKwnzweyZyAOqbiRatEkIZXAFfowEghliNMAAAABAAAAAAAAAAABY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloA=
6ddab1486dd944e4a374caf9a40a460416638e1578e3f17482acfd289c5cb847	41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	24128cf784e4c94f58a5a72a5036a54e82b2e37c1b1b327bd8af8ab48684abf6	2	1432222739	QTEKAYGjqC/xPASTaVBOl4c0zxfaG68C9+TYgehgg3HWnizXf2VvYXCoygkt/wDezda8dXZTRIUXo6e9UAqQU+OwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVJBKM94TkyU9YpacqUDalToKy43wbGzJ72K+KtIaEq/YAAAACAAAAAFVd/BMBY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloA=
c86af9e44867edb1580a0debc372353085f016f4754efef8fd003ba1a74bce3a	6ddab1486dd944e4a374caf9a40a460416638e1578e3f17482acfd289c5cb847	d4cc5c3790c8d1620d4a807bb3d74c2a6f7c3240b997a3a27452823bd1e72d2d	3	1432222740	bdqxSG3ZROSjdMr5pApGBBZjjhV44/F0gqz9KJxcuEe+WOVUjPxpYk7/OWuMPsNeUyg+U6Q9FVUXwsCdje+0K0JE8w0WffANIv0kKJlK202BOQJV4FNiNTT8gACU9G8M1MxcN5DI0WINSoB7s9dMKm98MkC5l6OidFKCO9HnLS0AAAADAAAAAFVd/BQBY0V4XYoAAAAAAAAAAAAoAAAAAAAAAAAAAAAAAAAACgCYloA=
f8b99b568ece0b2d7e83b515ea8b5a26fb771f873022c4e6477c9b6648f89e70	c86af9e44867edb1580a0debc372353085f016f4754efef8fd003ba1a74bce3a	254bc181cfe493f6dda80c6c0d45c38fd48f1204792a83cc795dbc93c8e432ac	4	1432222741	yGr55Ehn7bFYCg3rw3I1MIXwFvR1Tv74/QA7oadLzjr5ThX4b+P34hCo/O5yx18NlxT/fX3yqwmRw/UDjN4LGxZGu1TKD/Fc2YwrpcVDk5MUskih0RTBcPDVT6S5isUjJUvBgc/kk/bdqAxsDUXDj9SPEgR5KoPMeV28k8jkMqwAAAAEAAAAAFVd/BUBY0V4XYoAAAAAAAAAAABQAAAAAAAAAAAAAAAAAAAACgCYloA=
bdf3b040dae334bbdacc926943ddcc20b6ec83bbd94541f5e79f7f9d2ae1d379	f8b99b568ece0b2d7e83b515ea8b5a26fb771f873022c4e6477c9b6648f89e70	4aa4ed22e5faea505c19590edcdab78ca8508d74c3d48d69dfcd10793aa5181b	5	1432222742	+LmbVo7OCy1+g7UV6otaJvt3H4cwIsTmR3ybZkj4nnBDX80Bvo4uiev8LOWFjfwADYdVXIuZfgTTGAO6jDae91yaDRJ5rfPDxVXubzvOIGIKgOLAMHUi4qGbXFFwMGxqSqTtIuX66lBcGVkO3Nq3jKhQjXTD1I1p380QeTqlGBsAAAAFAAAAAFVd/BYBY0V4XYoAAAAAAAAAAABkAAAAAAAAAAAAAAAAAAAACgCYloA=
ac0d829180cb3c9b648f384ac994e9b6611cd983d87a1b53ec3a4e42a8ef98f2	bdf3b040dae334bbdacc926943ddcc20b6ec83bbd94541f5e79f7f9d2ae1d379	add6b7f7b035ac0ca941bf41bfaab83aecca152b0019d6b4768b0d6673b7fe77	6	1432222743	vfOwQNrjNLvazJJpQ93MILbsg7vZRUH1559/nSrh03lw/WJ2F/LVZh1tqKetuQqdkmfIaOuihwKRLNzcI+EmLryZStZocdzGUzmefJ7X9gLeQjgSSMUNwSVXCpxNm1lfrda397A1rAypQb9Bv6q4OuzKFSsAGda0dosNZnO3/ncAAAAGAAAAAFVd/BcBY0V4XYoAAAAAAAAAAACCAAAAAAAAAAAAAAADAAAACgCYloA=
6bbe40d7fcca5d55b59d0ad2c3a6e972a7ea1761602cc52160c09592ca0e395a	ac0d829180cb3c9b648f384ac994e9b6611cd983d87a1b53ec3a4e42a8ef98f2	3d6b624bad6afa6f3b021f71931c6b8d50c33c9f33539b6da5ebfa1dc7c69f5f	7	1432222744	rA2CkYDLPJtkjzhKyZTptmEc2YPYehtT7DpOQqjvmPIR1gmNXWdDj7y+K9M36Y6PMH9+VFGSHnyrKpHSJQBN6ow8JuqOzmfLLX8OO6djzJBCgRJA4xy/hYo90L2VeR5UPWtiS61q+m87Ah9xkxxrjVDDPJ8zU5ttpev6HcfGn18AAAAHAAAAAFVd/BgBY0V4XYoAAAAAAAAAAACWAAAAAAAAAAAAAAAEAAAACgCYloA=
\.


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY offers (accountid, offerid, paysalphanumcurrency, paysissuer, getsalphanumcurrency, getsissuer, amount, pricen, priced, price) FROM stdin;
gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	2	USD	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	EUR	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	1111111111	10	9	11111111
gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	3	USD	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	EUR	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	1250000000	5	4	12500000
gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	1	USD	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	EUR	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	500000000	1	1	10000000
gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	4	\N	\N	USD	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	500000000	1	1	10000000
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
databaseinitialized             	true
forcescponnextlaunch            	false
lastclosedledger                	6bbe40d7fcca5d55b59d0ad2c3a6e972a7ea1761602cc52160c09592ca0e395a
historyarchivestate             	{\n    "version": 0,\n    "currentLedger": 7,\n    "currentBuckets": [\n        {\n            "curr": "f91b822b374fcddc3eaf0efbaa33dda9edc3b4fd2644337944c29ab6f2d08fe1",\n            "next": {\n                "state": 0\n            },\n            "snap": "fa05fc77c71113cc6b0ee720e790c6a2c918e0ba1b81daec43650dc94963ab96"\n        },\n        {\n            "curr": "58e34b94341d17678629371b0c52d2dfa251fb8de8a874cdc79d912282919cc3",\n            "next": {\n                "state": 1,\n                "output": "fa05fc77c71113cc6b0ee720e790c6a2c918e0ba1b81daec43650dc94963ab96"\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        }\n    ]\n}
\.


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY trustlines (accountid, issuer, alphanumcurrency, tlimit, balance, flags) FROM stdin;
gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	USD	9223372036854775807	500000000	1
gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	EUR	9223372036854775807	4500000000	1
gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	EUR	9223372036854775807	500000000	1
gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	USD	9223372036854775807	4500000000	1
\.


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY txhistory (txid, ledgerseq, txindex, txbody, txresult, txmeta) FROM stdin;
663b58919ee418808c37a22d28ef64cda597595d14c40d7d8609f339af7b8259	3	1	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAOoaD55mPlWeWdnL4sjTMp4YcX5Lgylkwom28GqHoyAsAAAAADuaygAAAAABiZsoQLptYZoGkjQYDS3kNRI7+uv5o6GWz0oFjMmiU0eO5m6vhspCbOPfcw45ZuNXnY7B8BBSWsmGGIH/7JJo49eNsg8=	ZjtYkZ7kGICMN6ItKO9kzaWXWV0UxA19hgnzOa97glkAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAA6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAAAO5rKAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAACJmyhA7VY2xW3cXxSyOXX3nxuiOI0mlOTFbs3dyWDl7wFjRXgh7zX2AAAAAAAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA=
8a1ca0b7cdbe8306dd6c21d4be55401fca61f575361c2feed152aa2c5c949196	3	2	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAIAAAAAAAAAAAAAAAEAAAAAAAAAAIjtWWs+lb+JGeNBHe25jor21dU7i8oOLtrr58dWqNytAAAAADuaygAAAAABiZsoQFahtiMbo5ZoPiKAY4xHRdGLX06qDoCSgdHJpFviS6lHiWqGY11oNiKQ85UBmC8jwHSzhTMvzFgkz+j/q7rRzQ8=	ihygt82+gwbdbCHUvlVAH8ph9XU2HC/u0VKqLFyUkZYAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAAiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAAO5rKAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAACJmyhA7VY2xW3cXxSyOXX3nxuiOI0mlOTFbs3dyWDl7wFjRXfmVGvsAAAAAAAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA=
28204d3b1e2fe7a2bceb2832cd3e2030e9f3b7e5cd5d1ee3b7228c057c341eaa	3	3	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAMAAAAAAAAAAAAAAAEAAAAAAAAAAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAADuaygAAAAABiZsoQMgv8UWNvBUSWBxnkzgtaOIueoYoTAZE/RBTitkVcdHKPN2a/Dv+KMP4uZg2qczMa8lMJ+q+8ivihbz3nuxC/AU=	KCBNOx4v56K86ygyzT4gMOnzt+XNXR7jtyKMBXw0HqoAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAAAO5rKAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAACJmyhA7VY2xW3cXxSyOXX3nxuiOI0mlOTFbs3dyWDl7wFjRXequaHiAAAAAAAAAAMAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA=
ce7df370cae7443cb8114480fc80b1f6d3240abe1bfcd0344169cf289ec7ce12	3	4	iZsoQO1WNsVt3F8Usjl1958bojiNJpTkxW7N3clg5e8AAAAKAAAAAAAAAAQAAAAAAAAAAAAAAAEAAAAAAAAAAEb/mui32dh3EJ3gYQ91foGZ/fpTgGVkHhJgJ8POyA/BAAAAADuaygAAAAABiZsoQGZJb6W5GsXLg7r8hE6BXGzoy4QsY6Gwj7pK+vLTtd0eUmqJk/Z8G2eNSVO9y5Zfjrxwpr4gcNMcOEx3eE26AQI=	zn3zcMrnRDy4EUSA/ICx9tMkCr4b/NA0QWnPKJ7HzhIAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAA	AAAAAgAAAAAAAAAARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAAAO5rKAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAACJmyhA7VY2xW3cXxSyOXX3nxuiOI0mlOTFbs3dyWDl7wFjRXdvHtfYAAAAAAAAAAQAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA=
140f1354fd827369d2c5b246cf8a24289d8d99c5d4455423884db5be9e95208e	4	1	6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAAKAAAAAwAAAAEAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPB//////////wAAAAHqGg+eCopZEod1xoAag+dGLGoyxPfZ5Koj3g9BIREFSWy0eSQpk70S0f5N21TX87AlJTIEd20XJL+Gugrvz32s1KRwDg==	FA8TVP2Cc2nSxbJGz4okKJ2NmcXURVQjiE21vp6VII4AAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAgAAAAAAAAAB6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAAAAAAAB//////////wAAAAEAAAABAAAAAOoaD55mPlWeWdnL4sjTMp4YcX5Lgylkwom28GqHoyAsAAAAADuayfYAAAADAAAAAQAAAAEAAAAAAAAAAAEAAAAAAAAAAAAAAA==
9f2bc7cef164391b7172a7b709fc28944a559682a784bba1c0351dfb115fcf57	4	2	iO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAKAAAAAwAAAAEAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPB//////////wAAAAGI7VlriayFK/4BLPkmKV6s/u6w1sZSEterAoZowgjgOljED4sWHA696rZ25+/K3MiW31JyjfpqYqwwMcEfA6iu3NPRAw==	nyvHzvFkORtxcqe3CfwolEpVloKnhLuhwDUd+xFfz1cAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAgAAAAAAAAABiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAAAAAAAB//////////wAAAAEAAAABAAAAAIjtWWs+lb+JGeNBHe25jor21dU7i8oOLtrr58dWqNytAAAAADuayfYAAAADAAAAAQAAAAEAAAAAAAAAAAEAAAAAAAAAAAAAAA==
e5463115c134f01598fa417ebdaa841d53b753b15981943e373b303348ed13f8	4	3	iO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAKAAAAAwAAAAIAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8F//////////wAAAAGI7Vlr67ybetxAOrRHRex9Qwq/F4kBpYSlRakLnJO/yqJjARzuyDro9UeyxvQoiAqKoOyAPcKhsAVVwmKSeRfbUhtHCQ==	5UYxFcE08BWY+kF+vaqEHVO3U7FZgZQ+NzswM0jtE/gAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAgAAAAAAAAABiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAABRVVSAEb/mui32dh3EJ3gYQ91foGZ/fpTgGVkHhJgJ8POyA/BAAAAAAAAAAB//////////wAAAAEAAAABAAAAAIjtWWs+lb+JGeNBHe25jor21dU7i8oOLtrr58dWqNytAAAAADuayewAAAADAAAAAgAAAAIAAAAAAAAAAAEAAAAAAAAAAAAAAA==
426c6232f0c741c940a26660c91f8327bce2f0b17e498ff33d3a6f3c1e43c99a	4	4	6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAAKAAAAAwAAAAIAAAAAAAAAAAAAAAEAAAAAAAAABQAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8F//////////wAAAAHqGg+eI42eYx4zc8EBdrd+lqtYd2Yl6FAPPizCDQbqTTLyvpPz49+D7BOOGZM6DkZj4FEo8kjVVSzD11Rl0YsDJEJJBA==	QmxiMvDHQclAomZgyR+DJ7zi8LF+SY/zPTpvPB5DyZoAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAA	AAAAAgAAAAAAAAAB6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAABRVVSAEb/mui32dh3EJ3gYQ91foGZ/fpTgGVkHhJgJ8POyA/BAAAAAAAAAAB//////////wAAAAEAAAABAAAAAOoaD55mPlWeWdnL4sjTMp4YcX5Lgylkwom28GqHoyAsAAAAADuayewAAAADAAAAAgAAAAIAAAAAAAAAAAEAAAAAAAAAAAAAAA==
82704f676ca50edb945c7074e6b7d795e13d0b4e5aac7263a54b4cf0eaa54131	5	1	/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAAKAAAAAwAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAeoaD55mPlWeWdnL4sjTMp4YcX5Lgylkwom28GqHoyAsAAAAAVVTRAD+3aaMbCFo8FiK+hv2p24/sXjPhCcRq0mLHX3BpT0I8AAAAAEqBfIAAAAAAf7dpowRFG1neciyo365CRjgGX2ofKksXChXx8v4UHtQXvpc+I39Imyfsxs5zDqM2wGBYwMYxM796drerrqP13yiZpoK	gnBPZ2ylDtuUXHB05rfXleE9C05arHJjpUtM8OqlQTEAAAAAAAAACgAAAAAAAAABAAAAAAAAAAEAAAAA	AAAAAgAAAAEAAAAA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAAAO5rJ9gAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAAHqGg+eZj5VnlnZy+LI0zKeGHF+S4MpZMKJtvBqh6MgLAAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAABKgXyAH//////////AAAAAQ==
8f69a0c3788d8d5340339e69fa9361259b19caaf62b71b2bbe6aadc02bd4e555	5	2	Rv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAAKAAAAAwAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAYjtWWs+lb+JGeNBHe25jor21dU7i8oOLtrr58dWqNytAAAAAUVVUgBG/5rot9nYdxCd4GEPdX6Bmf36U4BlZB4SYCfDzsgPwQAAAAEqBfIAAAAAAUb/muic3zoutEXtDFC5v9WZQ2LLgBpOdazrfM7Wm+sJ0joxYtVsvZZvUJ83GnRxzC6qRP9JknvAhRVrhhy2ggXINrYE	j2mgw3iNjVNAM55p+pNhJZsZyq9itxsrvmqtwCvU5VUAAAAAAAAACgAAAAAAAAABAAAAAAAAAAEAAAAA	AAAAAgAAAAEAAAAARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAAAO5rJ9gAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAAGI7VlrPpW/iRnjQR3tuY6K9tXVO4vKDi7a6+fHVqjcrQAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABKgXyAH//////////AAAAAQ==
7d71c628e9e38b3abaa3c14e78080b4283431c6c357cc8a39436bb2358596b64	6	1	iO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAKAAAAAwAAAAMAAAAAAAAAAAAAAAEAAAAAAAAAAwAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAADuaygAAAAABAAAAAQAAAAAAAAAAAAAAAYjtWWvvmqbF7M4AABfSmPgKxfwSzVqTS0SEMfS2UHOL7F1JMzkL4Sl8S2zMxLy/tZmC56D++6qslnzGItSW8qNXEasK	fXHGKOnjizq6o8FOeAgLQoNDHGw1fMijlDa7I1hZa2QAAAAAAAAACgAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAACI7VlrPpW/iRnjQR3tuY6K9tXVO4vKDi7a6+fHVqjcrQAAAAAAAAABAAAAAUVVUgBG/5rot9nYdxCd4GEPdX6Bmf36U4BlZB4SYCfDzsgPwQAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAAAO5rKAAAAAAEAAAAB	AAAAAgAAAAAAAAACiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAAAAAAAQAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAADuaygAAAAABAAAAAQAAAAEAAAAAiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAAO5rJ4gAAAAMAAAADAAAAAwAAAAAAAAAAAQAAAAAAAAAAAAAA
82a78dadeb868eb727971fba96a6e1ca3c3f1b607b8ba643551d16454e294baf	6	2	iO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAKAAAAAwAAAAQAAAAAAAAAAAAAAAEAAAAAAAAAAwAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAAEI6NccAAAAKAAAACQAAAAAAAAAAAAAAAYjtWWu5PE3Sy+8YN2szzoDixHhVMLZCdaScCFzK0meOh338akfF1hBdSLA8SezV12NbGTjS72Xi5Ma0ubG81sBFP1AM	gqeNreuGjrcnlx+6lqbhyjw/G2B7i6ZDVR0WRU4pS68AAAAAAAAACgAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAACI7VlrPpW/iRnjQR3tuY6K9tXVO4vKDi7a6+fHVqjcrQAAAAAAAAACAAAAAUVVUgBG/5rot9nYdxCd4GEPdX6Bmf36U4BlZB4SYCfDzsgPwQAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAAAQjo1xwAAAAoAAAAJ	AAAAAgAAAAAAAAACiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAAAAAAAgAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAAEI6NccAAAAKAAAACQAAAAEAAAAAiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAAO5rJ2AAAAAMAAAAEAAAABAAAAAAAAAAAAQAAAAAAAAAAAAAA
c915062e56d23bd8725ca98eefa135848f35103a918bfcad20928fcc429a20c9	6	3	iO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAKAAAAAwAAAAUAAAAAAAAAAAAAAAEAAAAAAAAAAwAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAAEqBfIAAAAAFAAAABAAAAAAAAAAAAAAAAYjtWWtmVmK7+oouIrzhjiP3dNm4V4oHCU1gdtPMqtuF+fTbK2QuPniYx1SfaxjuLQFhsbh4YayrzKbEpVhRrVUXUfYP	yRUGLlbSO9hyXKmO76E1hI81EDqRi/ytIJKPzEKaIMkAAAAAAAAACgAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAACI7VlrPpW/iRnjQR3tuY6K9tXVO4vKDi7a6+fHVqjcrQAAAAAAAAADAAAAAUVVUgBG/5rot9nYdxCd4GEPdX6Bmf36U4BlZB4SYCfDzsgPwQAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAAASoF8gAAAAAUAAAAE	AAAAAgAAAAAAAAACiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAAAAAAAwAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAAEqBfIAAAAAFAAAABAAAAAEAAAAAiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAAO5rJzgAAAAMAAAAFAAAABQAAAAAAAAAAAQAAAAAAAAAAAAAA
9a01a4460c6581e53d8bb4966ace81ca60fa4d12d51b75007ba1c0abe6f2c484	7	1	6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAAKAAAAAwAAAAMAAAAAAAAAAAAAAAEAAAAAAAAAAwAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAABRVVSAEb/mui32dh3EJ3gYQ91foGZ/fpTgGVkHhJgJ8POyA/BAAAAAB3NZQAAAAABAAAAAQAAAAAAAAAAAAAAAeoaD54X/k3c8fap1tX7BAToCyubIHDVL9oR7mbhD0v//4yFc5DC7KPfNFcxGEZhJcZRAwf4dwP5fw3aepwJih3i3GcP	mgGkRgxlgeU9i7SWas6BymD6TRLVG3UAe6HAq+byxIQAAAAAAAAACgAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAYjtWWs+lb+JGeNBHe25jor21dU7i8oOLtrr58dWqNytAAAAAAAAAAEAAAABRVVSAEb/mui32dh3EJ3gYQ91foGZ/fpTgGVkHhJgJ8POyA/BAAAAAB3NZQAAAAAC	AAAABgAAAAEAAAAA6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAAAO5rJ4gAAAAMAAAADAAAAAgAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQAAAAGI7VlrPpW/iRnjQR3tuY6K9tXVO4vKDi7a6+fHVqjcrQAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABDDiNAH//////////AAAAAQAAAAEAAAABiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAAB3NZQB//////////wAAAAEAAAABAAAAAeoaD55mPlWeWdnL4sjTMp4YcX5Lgylkwom28GqHoyAsAAAAAUVVUgBG/5rot9nYdxCd4GEPdX6Bmf36U4BlZB4SYCfDzsgPwQAAAAAdzWUAf/////////8AAAABAAAAAQAAAAHqGg+eZj5VnlnZy+LI0zKeGHF+S4MpZMKJtvBqh6MgLAAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAABDDiNAH//////////AAAAAQAAAAEAAAACiO1Zaz6Vv4kZ40Ed7bmOivbV1TuLyg4u2uvnx1ao3K0AAAAAAAAAAQAAAAFFVVIARv+a6LfZ2HcQneBhD3V+gZn9+lOAZWQeEmAnw87ID8EAAAABVVNEAP7dpoxsIWjwWIr6G/anbj+xeM+EJxGrSYsdfcGlPQjwAAAAAB3NZQAAAAABAAAAAQ==
ae0bc00fddbd117b9786f4a8ce2e1bb506aa7401a29778f8fc23c013498318df	7	2	6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAAKAAAAAwAAAAQAAAAAAAAAAAAAAAEAAAAAAAAAAwAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAAAAAAAAB3NZQAAAAABAAAAAQAAAAAAAAAAAAAAAeoaD54QRXIRxf0MrNOoRtSLe1W0rrVFOk6A+IW+C0e70uLidjJSjhXvhx+av+Fo6uN/nw/pnHrNZBKiI3FDcsWYCIsN	rgvAD929EXuXhvSozi4btQaqdAGil3j4/CPAE0mDGN8AAAAAAAAACgAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAADqGg+eZj5VnlnZy+LI0zKeGHF+S4MpZMKJtvBqh6MgLAAAAAAAAAAEAAAAAVVTRAD+3aaMbCFo8FiK+hv2p24/sXjPhCcRq0mLHX3BpT0I8AAAAAAAAAAAHc1lAAAAAAEAAAAB	AAAAAgAAAAAAAAAC6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAAAAAAABAAAAAFVU0QA/t2mjGwhaPBYivob9qduP7F4z4QnEatJix19waU9CPAAAAAAAAAAAB3NZQAAAAABAAAAAQAAAAEAAAAA6hoPnmY+VZ5Z2cviyNMynhhxfkuDKWTCibbwaoejICwAAAAAO5rJ2AAAAAMAAAAEAAAAAwAAAAAAAAAAAQAAAAAAAAAAAAAA
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
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM nullstyle;
GRANT ALL ON SCHEMA public TO nullstyle;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

