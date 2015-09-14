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
DROP INDEX public.priceindex;
DROP INDEX public.ledgersbyseq;
DROP INDEX public.buyingissuerindex;
DROP INDEX public.accountlines;
DROP INDEX public.accountbalances;
ALTER TABLE ONLY public.txhistory DROP CONSTRAINT txhistory_pkey;
ALTER TABLE ONLY public.txhistory DROP CONSTRAINT txhistory_ledgerseq_txindex_key;
ALTER TABLE ONLY public.trustlines DROP CONSTRAINT trustlines_pkey;
ALTER TABLE ONLY public.storestate DROP CONSTRAINT storestate_pkey;
ALTER TABLE ONLY public.signers DROP CONSTRAINT signers_pkey;
ALTER TABLE ONLY public.pubsub DROP CONSTRAINT pubsub_pkey;
ALTER TABLE ONLY public.peers DROP CONSTRAINT peers_pkey;
ALTER TABLE ONLY public.offers DROP CONSTRAINT offers_pkey;
ALTER TABLE ONLY public.ledgerheaders DROP CONSTRAINT ledgerheaders_pkey;
ALTER TABLE ONLY public.ledgerheaders DROP CONSTRAINT ledgerheaders_ledgerseq_key;
ALTER TABLE ONLY public.accounts DROP CONSTRAINT accounts_pkey;
DROP TABLE public.txhistory;
DROP TABLE public.trustlines;
DROP TABLE public.storestate;
DROP TABLE public.signers;
DROP TABLE public.pubsub;
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
    homedomain character varying(32),
    thresholds text,
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
    sellingassettype integer,
    sellingassetcode character varying(12),
    sellingissuer character varying(56),
    buyingassettype integer,
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
    rank integer DEFAULT 0 NOT NULL,
    CONSTRAINT peers_numfailures_check CHECK ((numfailures >= 0)),
    CONSTRAINT peers_port_check CHECK (((port > 0) AND (port <= 65535))),
    CONSTRAINT peers_rank_check CHECK ((rank >= 0))
);


--
-- Name: pubsub; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pubsub (
    resid character(32) NOT NULL,
    lastread integer
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
    tlimit bigint DEFAULT 0 NOT NULL,
    balance bigint DEFAULT 0 NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
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

COPY accounts (accountid, balance, seqnum, numsubentries, inflationdest, homedomain, thresholds, flags, lastmodified) FROM stdin;
GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	80015257680000001	3	0	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H		AQAAAA==	0	3
GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	20003814419999997	8589934593	0	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU		AQAAAA==	0	3
\.


--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY ledgerheaders (ledgerhash, prevhash, bucketlisthash, ledgerseq, closetime, data) FROM stdin;
5ade5048fb66795219cbb45a55bf5e2710f739610d10e6875bf7f85d85900669	0000000000000000000000000000000000000000000000000000000000000000	759f642a94be58e4118ef79bd7f343832a82db2fc4f98f41ee7d22b61df716ed	1	0	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB1n2QqlL5Y5BGO95vX80ODKoLbL8T5j0HufSK2HfcW7QAAAAEBY0V4XYoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgCYloAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
d9241e78bd5245f84a691d7a183e622acb8250bf744609df84d1106c4f24ad0d	5ade5048fb66795219cbb45a55bf5e2710f739610d10e6875bf7f85d85900669	177cdf31c3e6995c4207b2b929fe09c63fa9dfad97bd497608c19c1b12c1c165	2	1442245209	AAAAAVreUEj7ZnlSGcu0WlW/XicQ9zlhDRDmh1v3+F2FkAZpnK2kowFofaxzTk21gI2Rs5uVvWX3yScuIEpiyMZXSp4AAAAAVfbqWQAAAAEAAAAIAAAAAQAAAAEAAAAArxU2BS3cCqWvTwISBYWEzwBuPm1XDE+otiORbVsQIO0XfN8xw+aZXEIHsrkp/gnGP6nfrZe9SXYIwZwbEsHBZQAAAAIBY0V4XYoAAAAAAAAAAAAKAAAAAAAAAAAAAAAAAAAACgCYloAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
df360ab621a376c47fd3d0b682885e5a485862731aad8d95170acb37b69dbe5f	d9241e78bd5245f84a691d7a183e622acb8250bf744609df84d1106c4f24ad0d	5f2ffd68309f3634ee3cb00b9e358620172f75bb6dbc9ebcf91ad023fa0edd69	3	1442245210	AAAAAdkkHni9UkX4Smkdehg+YirLglC/dEYJ34TREGxPJK0Ny36VvLuGZLwGgx8Glhx2NA0yl3A7oZM6Ce3ydzCS3vMAAAAAVfbqWgAAAAAAAAAAF6YAkGOVvD8sFgScUvtNl9r6s9ulV5fPxySWSqQjqplfL/1oMJ82NO48sAueNYYgFy91u228nrz5GtAj+g7daQAAAAMBY1bQ70jhJgAAAAAAAAACAAAAAQAAAAAAAAAAAAAACgCYloAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
\.


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY offers (sellerid, offerid, sellingassettype, sellingassetcode, sellingissuer, buyingassettype, buyingassetcode, buyingissuer, amount, pricen, priced, price, flags, lastmodified) FROM stdin;
\.


--
-- Data for Name: peers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY peers (ip, port, nextattempt, numfailures, rank) FROM stdin;
\.


--
-- Data for Name: pubsub; Type: TABLE DATA; Schema: public; Owner: -
--

COPY pubsub (resid, lastread) FROM stdin;
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
lastclosedledger                	df360ab621a376c47fd3d0b682885e5a485862731aad8d95170acb37b69dbe5f
historyarchivestate             	{\n    "version": 1,\n    "server": "ad6891f",\n    "currentLedger": 3,\n    "currentBuckets": [\n        {\n            "curr": "7ab9bdd9881716bf57ca63c516672a010bdc9b0c0bac049492eff32b6cf527dc",\n            "next": {\n                "state": 0\n            },\n            "snap": "936f3d81329f7c1a77aa8408d6ef5f6de032a4c866e799e4755ec0e752c8f768"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 1,\n                "output": "936f3d81329f7c1a77aa8408d6ef5f6de032a4c866e799e4755ec0e752c8f768"\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        },\n        {\n            "curr": "0000000000000000000000000000000000000000000000000000000000000000",\n            "next": {\n                "state": 0\n            },\n            "snap": "0000000000000000000000000000000000000000000000000000000000000000"\n        }\n    ]\n}
\.


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY trustlines (accountid, assettype, issuer, assetcode, tlimit, balance, flags, lastmodified) FROM stdin;
\.


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY txhistory (txid, ledgerseq, txindex, txbody, txresult, txmeta) FROM stdin;
8f922b7bc413cd8c2928bbbf5c5fc7b3a52be1b45503a6b00319a3346fd7ee60	2	1	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwARw3k34IAAAAAAAAAAAABVvwF9wAAAEA4pvilLw1Ut2Rh1s0Wcw356mcIfWnB8Mejz0MeLytBTzoWtvsr8Zc0uoNv62tpBAfC4IShTyQxRs9kk7UIXz8D	j5Ire8QTzYwpKLu/XF/Hs6Ur4bRVA6awAxmjNG/X7mAAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAgAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBY0V4XYn/9gAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAAAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TABHDeTfggAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wEcN5N+B//2AAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
d84c9fe76a3ceaf84dae82b772045418427f2793ee9ae8adaf2e282bb3c0b7ad	3	1	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABruS+TAAAAEDxtfJQXuFB3UEWjFYkF2G/pftI2JAvJG1ecYW5trJSvVyNPo8mDQm1/b4F1gaaFEhEHYxbcn4AlQEQQoqlO1IE	2Eyf52o86vhNroK3cgRUGEJ/J5Pumuitry4oK7PAt60AAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAwAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwARw3k34H/9gAAAAIAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TABHDeTfgf/2AAAAAgAAAAEAAAAAAAAAAQAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
3b7613e1974670e2b0cb67692250a517d345b3fa87698a8a2e85e9be48bb41b1	3	2	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABVvwF9wAAAEC+rc/VUiOm49jvKktO9000n2ActZVoJ6J54K3EiruR/I9qwM+ncX9Dh7xT/uE/YO2VX5HJP6Tv3/Iujn0LFHwL	O3YT4ZdGcOKwy2dpIlClF9NFs/qHaYqKLoXpvki7QbEAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAwAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBHDeTfgf/7AAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAADAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wEcN5N+B//sAAAAAAAAAAIAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
eb8b2f2a3a74f6daa5b393c447d0429f39d9c7f9af3878f9b71746ee10f40db1	3	3	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAkAAAAAAAAAAVb8BfcAAABAhmhQ4I3KbaxxXbVZqI9zOiEY5hteFjhX8XlrlmZXzB8q+pDKfc97328MXWTFWuohQvxS7QN/jVIcDfON6GzAAQ==	64svKjp09tqls5PER9BCnznZx/mvOHj5txdG7hD0DbEAAAAAAAAACgAAAAAAAAABAAAAAAAAAAkAAAAAAAAAAgAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAADeB0mLQfAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAADeB0mLQcAAAAA	AAAAAAAAAAEAAAABAAAAAwAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBHDeTfgf/4gAAAAAAAAADAAAAAAAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAEAAAADAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wEcRXPyoLQBAAAAAAAAAAMAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TABHEVz8qCz9AAAAAgAAAAEAAAAAAAAAAQAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
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
-- Name: pubsub_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pubsub
    ADD CONSTRAINT pubsub_pkey PRIMARY KEY (resid);


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

CREATE INDEX accountbalances ON accounts USING btree (balance) WHERE (balance >= 1000000000);


--
-- Name: accountlines; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX accountlines ON trustlines USING btree (accountid);


--
-- Name: buyingissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX buyingissuerindex ON offers USING btree (buyingissuer);


--
-- Name: ledgersbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ledgersbyseq ON ledgerheaders USING btree (ledgerseq);


--
-- Name: priceindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX priceindex ON offers USING btree (price);


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

