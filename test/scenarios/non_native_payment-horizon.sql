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

DROP INDEX public.unique_schema_migrations;
DROP INDEX public.index_history_transaction_statuses_lc_on_all;
DROP INDEX public.index_history_transaction_participants_on_transaction_hash;
DROP INDEX public.index_history_transaction_participants_on_account;
DROP INDEX public.index_history_ledgers_on_sequence;
DROP INDEX public.index_history_ledgers_on_previous_ledger_hash;
DROP INDEX public.index_history_ledgers_on_ledger_hash;
DROP INDEX public.index_history_ledgers_on_closed_at;
DROP INDEX public.by_status;
DROP INDEX public.by_ledger;
DROP INDEX public.by_hash;
DROP INDEX public.by_account;
ALTER TABLE ONLY public.history_transaction_statuses DROP CONSTRAINT history_transaction_statuses_pkey;
ALTER TABLE ONLY public.history_transaction_participants DROP CONSTRAINT history_transaction_participants_pkey;
ALTER TABLE public.history_transaction_statuses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.history_transaction_participants ALTER COLUMN id DROP DEFAULT;
DROP TABLE public.schema_migrations;
DROP TABLE public.history_transactions;
DROP SEQUENCE public.history_transaction_statuses_id_seq;
DROP TABLE public.history_transaction_statuses;
DROP SEQUENCE public.history_transaction_participants_id_seq;
DROP TABLE public.history_transaction_participants;
DROP TABLE public.history_ledgers;
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
-- Name: history_ledgers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_ledgers (
    sequence integer NOT NULL,
    ledger_hash character varying(64) NOT NULL,
    previous_ledger_hash character varying(64),
    transaction_count integer DEFAULT 0 NOT NULL,
    operation_count integer DEFAULT 0 NOT NULL,
    closed_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "order" bigint
);


--
-- Name: history_transaction_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transaction_participants (
    id integer NOT NULL,
    transaction_hash character varying(64) NOT NULL,
    account character varying(64) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_transaction_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_transaction_participants_id_seq OWNED BY history_transaction_participants.id;


--
-- Name: history_transaction_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transaction_statuses (
    id integer NOT NULL,
    result_code_s character varying(255) NOT NULL,
    result_code integer NOT NULL
);


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_transaction_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_transaction_statuses_id_seq OWNED BY history_transaction_statuses.id;


--
-- Name: history_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transactions (
    transaction_hash character varying(64) NOT NULL,
    ledger_sequence integer NOT NULL,
    application_order integer NOT NULL,
    account character varying(64) NOT NULL,
    account_sequence bigint NOT NULL,
    max_fee integer NOT NULL,
    fee_paid integer NOT NULL,
    operation_count integer NOT NULL,
    transaction_status_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "order" bigint
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_participants ALTER COLUMN id SET DEFAULT nextval('history_transaction_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_statuses ALTER COLUMN id SET DEFAULT nextval('history_transaction_statuses_id_seq'::regclass);


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, "order") FROM stdin;
1	43cf4db3741a7d6c2322e7b646320ce9d7b099a0b3501734dcf70e74a8a4e637	\N	0	0	1970-01-01 00:00:00	2015-05-01 22:38:32.987358	2015-05-01 22:38:32.987358	4294967296
2	d74bea932a00fb300e769f2662628c5e33b297855e3708ed41698ee1c1e979a5	43cf4db3741a7d6c2322e7b646320ce9d7b099a0b3501734dcf70e74a8a4e637	0	0	2015-05-01 22:38:31	2015-05-01 22:38:32.997423	2015-05-01 22:38:32.997423	8589934592
3	20e007c7427e3bea3ca048e078c68a4c160f3d42139fa4162c07544cc13a2bdb	d74bea932a00fb300e769f2662628c5e33b297855e3708ed41698ee1c1e979a5	0	0	2015-05-01 22:38:32	2015-05-01 22:38:33.006053	2015-05-01 22:38:33.006053	12884901888
4	4f0ab6663d0e3a22d469b75c884f218f2ded1d8b7d627dff3599a054d47d3124	20e007c7427e3bea3ca048e078c68a4c160f3d42139fa4162c07544cc13a2bdb	0	0	2015-05-01 22:38:33	2015-05-01 22:38:33.026495	2015-05-01 22:38:33.026495	17179869184
5	e904e3b9e82062803caf326976d6597b079b83e18ddc0f624dbbc09b64b1cedd	4f0ab6663d0e3a22d469b75c884f218f2ded1d8b7d627dff3599a054d47d3124	0	0	2015-05-01 22:38:34	2015-05-01 22:38:33.042313	2015-05-01 22:38:33.042313	21474836480
6	8dbc3ef6ac2a6748c126302da3b83ce50cabcf5afebf45936817e3f876224451	e904e3b9e82062803caf326976d6597b079b83e18ddc0f624dbbc09b64b1cedd	0	0	2015-05-01 22:38:35	2015-05-01 22:38:33.072333	2015-05-01 22:38:33.072333	25769803776
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
9	5f4757783fe158dce8fc1571cc66482b7bcb79487fce6b7c55b68d8154dd24bb	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-05-01 22:38:33.010018	2015-05-01 22:38:33.010018
10	5f4757783fe158dce8fc1571cc66482b7bcb79487fce6b7c55b68d8154dd24bb	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-01 22:38:33.011277	2015-05-01 22:38:33.011277
11	1f4426e221f3ef7271c0d84940512cae677dfd01c7049d6a6f675496258e13e2	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-05-01 22:38:33.014268	2015-05-01 22:38:33.014268
12	1f4426e221f3ef7271c0d84940512cae677dfd01c7049d6a6f675496258e13e2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-01 22:38:33.015117	2015-05-01 22:38:33.015117
13	774e2ce667a8c4070f4d43e8f74ec86f549cee6344dfe582877be72859586a8e	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-05-01 22:38:33.018012	2015-05-01 22:38:33.018012
14	774e2ce667a8c4070f4d43e8f74ec86f549cee6344dfe582877be72859586a8e	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-01 22:38:33.018922	2015-05-01 22:38:33.018922
15	27461f6a0de4b4ae089d500ac5719552620c27c4c4f7c87a197a1b315bfd405c	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-05-01 22:38:33.030552	2015-05-01 22:38:33.030552
16	e8f2c211b668b4ce6ac7634ff4989e0cba1f260e74af34bae558be3a3cb2c4a1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-05-01 22:38:33.034131	2015-05-01 22:38:33.034131
17	fce5df0163ac62c8bbc8afc83f0aa1c0bdc13c9fbfb600117bd0db81db9cb91d	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-05-01 22:38:33.046632	2015-05-01 22:38:33.046632
18	67f7b0fade18c707bb95082b8abdbdf9881e4e44b7d83be54c807682db948f97	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-05-01 22:38:33.088457	2015-05-01 22:38:33.088457
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 18, true);


--
-- Data for Name: history_transaction_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_statuses (id, result_code_s, result_code) FROM stdin;
\.


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_statuses_id_seq', 1, false);


--
-- Data for Name: history_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transactions (transaction_hash, ledger_sequence, application_order, account, account_sequence, max_fee, fee_paid, operation_count, transaction_status_id, created_at, updated_at, "order") FROM stdin;
5f4757783fe158dce8fc1571cc66482b7bcb79487fce6b7c55b68d8154dd24bb	3	1	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	1	10	10	1	-1	2015-05-01 22:38:33.007984	2015-05-01 22:38:33.007984	12884905984
1f4426e221f3ef7271c0d84940512cae677dfd01c7049d6a6f675496258e13e2	3	2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2	10	10	1	-1	2015-05-01 22:38:33.012741	2015-05-01 22:38:33.012741	12884910080
774e2ce667a8c4070f4d43e8f74ec86f549cee6344dfe582877be72859586a8e	3	3	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	3	10	10	1	-1	2015-05-01 22:38:33.016517	2015-05-01 22:38:33.016517	12884914176
27461f6a0de4b4ae089d500ac5719552620c27c4c4f7c87a197a1b315bfd405c	4	1	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901889	10	10	1	-1	2015-05-01 22:38:33.028692	2015-05-01 22:38:33.028692	17179873280
e8f2c211b668b4ce6ac7634ff4989e0cba1f260e74af34bae558be3a3cb2c4a1	4	2	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901889	10	10	1	-1	2015-05-01 22:38:33.032385	2015-05-01 22:38:33.032385	17179877376
fce5df0163ac62c8bbc8afc83f0aa1c0bdc13c9fbfb600117bd0db81db9cb91d	5	1	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901889	10	10	1	-1	2015-05-01 22:38:33.04502	2015-05-01 22:38:33.04502	21474840576
67f7b0fade18c707bb95082b8abdbdf9881e4e44b7d83be54c807682db948f97	6	1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901890	10	10	1	-1	2015-05-01 22:38:33.0745	2015-05-01 22:38:33.0745	25769807872
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY schema_migrations (version) FROM stdin;
\.


--
-- Name: history_transaction_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_transaction_participants
    ADD CONSTRAINT history_transaction_participants_pkey PRIMARY KEY (id);


--
-- Name: history_transaction_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_transaction_statuses
    ADD CONSTRAINT history_transaction_statuses_pkey PRIMARY KEY (id);


--
-- Name: by_account; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_account ON history_transactions USING btree (account, account_sequence);


--
-- Name: by_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_hash ON history_transactions USING btree (transaction_hash);


--
-- Name: by_ledger; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_ledger ON history_transactions USING btree (ledger_sequence, application_order);


--
-- Name: by_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_status ON history_transactions USING btree (transaction_status_id);


--
-- Name: index_history_ledgers_on_closed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_ledgers_on_closed_at ON history_ledgers USING btree (closed_at);


--
-- Name: index_history_ledgers_on_ledger_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_ledger_hash ON history_ledgers USING btree (ledger_hash);


--
-- Name: index_history_ledgers_on_previous_ledger_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_previous_ledger_hash ON history_ledgers USING btree (previous_ledger_hash);


--
-- Name: index_history_ledgers_on_sequence; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_sequence ON history_ledgers USING btree (sequence);


--
-- Name: index_history_transaction_participants_on_account; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_transaction_participants_on_account ON history_transaction_participants USING btree (account);


--
-- Name: index_history_transaction_participants_on_transaction_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_transaction_participants_on_transaction_hash ON history_transaction_participants USING btree (transaction_hash);


--
-- Name: index_history_transaction_statuses_lc_on_all; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_transaction_statuses_lc_on_all ON history_transaction_statuses USING btree (id, result_code, result_code_s);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


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

