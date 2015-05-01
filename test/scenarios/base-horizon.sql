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
1	43cf4db3741a7d6c2322e7b646320ce9d7b099a0b3501734dcf70e74a8a4e637	\N	0	0	1970-01-01 00:00:00	2015-05-01 22:38:31.015882	2015-05-01 22:38:31.015882	4294967296
2	a97dbf31841abd8a81131866e95e04104ea85e16fa563595e27a4b744a7a0615	43cf4db3741a7d6c2322e7b646320ce9d7b099a0b3501734dcf70e74a8a4e637	0	0	2015-05-01 22:38:30	2015-05-01 22:38:31.037302	2015-05-01 22:38:31.037302	8589934592
3	28a9cbebe3ee7859524e7fcd68b2c467e45655522b277ec9d1a13a04a01d6974	a97dbf31841abd8a81131866e95e04104ea85e16fa563595e27a4b744a7a0615	0	0	2015-05-01 22:38:31	2015-05-01 22:38:31.049249	2015-05-01 22:38:31.049249	12884901888
4	e5b3240e82a2567d840d130cb666007a01506870b659724227fc0cf414c330b2	28a9cbebe3ee7859524e7fcd68b2c467e45655522b277ec9d1a13a04a01d6974	0	0	2015-05-01 22:38:32	2015-05-01 22:38:31.090652	2015-05-01 22:38:31.090652	17179869184
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
1	6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-05-01 22:38:31.068079	2015-05-01 22:38:31.068079
2	6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-01 22:38:31.069642	2015-05-01 22:38:31.069642
3	c31867b3ec0f745e0b2af87ee3f837a0dec71e270b072a9d3e93c557e74e2d60	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	2015-05-01 22:38:31.074008	2015-05-01 22:38:31.074008
4	c31867b3ec0f745e0b2af87ee3f837a0dec71e270b072a9d3e93c557e74e2d60	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-01 22:38:31.075359	2015-05-01 22:38:31.075359
5	774e2ce667a8c4070f4d43e8f74ec86f549cee6344dfe582877be72859586a8e	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-05-01 22:38:31.079059	2015-05-01 22:38:31.079059
6	774e2ce667a8c4070f4d43e8f74ec86f549cee6344dfe582877be72859586a8e	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-01 22:38:31.080201	2015-05-01 22:38:31.080201
7	e0aae5e78c5211ae7de72321cfb5090ea108e60615bb5f1bd4ff94046aa10605	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-05-01 22:38:31.09424	2015-05-01 22:38:31.09424
8	e0aae5e78c5211ae7de72321cfb5090ea108e60615bb5f1bd4ff94046aa10605	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-05-01 22:38:31.095253	2015-05-01 22:38:31.095253
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 8, true);


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
6391dd190f15f7d1665ba53c63842e368f485651a53d8d852ed442a446d1c69a	3	1	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	1	10	10	1	-1	2015-05-01 22:38:31.059768	2015-05-01 22:38:31.059768	12884905984
c31867b3ec0f745e0b2af87ee3f837a0dec71e270b072a9d3e93c557e74e2d60	3	2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2	10	10	1	-1	2015-05-01 22:38:31.071733	2015-05-01 22:38:31.071733	12884910080
774e2ce667a8c4070f4d43e8f74ec86f549cee6344dfe582877be72859586a8e	3	3	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	3	10	10	1	-1	2015-05-01 22:38:31.077332	2015-05-01 22:38:31.077332	12884914176
e0aae5e78c5211ae7de72321cfb5090ea108e60615bb5f1bd4ff94046aa10605	4	1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901889	10	10	1	-1	2015-05-01 22:38:31.092586	2015-05-01 22:38:31.092586	17179873280
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

