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
DROP INDEX public.index_history_operations_on_type;
DROP INDEX public.index_history_operations_on_transaction_id;
DROP INDEX public.index_history_operations_on_id;
DROP INDEX public.index_history_ledgers_on_sequence;
DROP INDEX public.index_history_ledgers_on_previous_ledger_hash;
DROP INDEX public.index_history_ledgers_on_ledger_hash;
DROP INDEX public.index_history_ledgers_on_closed_at;
DROP INDEX public.index_history_accounts_on_id;
DROP INDEX public.hs_transaction_by_id;
DROP INDEX public.hs_ledger_by_id;
DROP INDEX public.hist_op_p_id;
DROP INDEX public.by_status;
DROP INDEX public.by_ledger;
DROP INDEX public.by_hash;
DROP INDEX public.by_account;
ALTER TABLE ONLY public.history_transaction_statuses DROP CONSTRAINT history_transaction_statuses_pkey;
ALTER TABLE ONLY public.history_transaction_participants DROP CONSTRAINT history_transaction_participants_pkey;
ALTER TABLE ONLY public.history_operation_participants DROP CONSTRAINT history_operation_participants_pkey;
ALTER TABLE public.history_transaction_statuses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.history_transaction_participants ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.history_operation_participants ALTER COLUMN id DROP DEFAULT;
DROP TABLE public.schema_migrations;
DROP TABLE public.history_transactions;
DROP SEQUENCE public.history_transaction_statuses_id_seq;
DROP TABLE public.history_transaction_statuses;
DROP SEQUENCE public.history_transaction_participants_id_seq;
DROP TABLE public.history_transaction_participants;
DROP TABLE public.history_operations;
DROP SEQUENCE public.history_operation_participants_id_seq;
DROP TABLE public.history_operation_participants;
DROP TABLE public.history_ledgers;
DROP TABLE public.history_accounts;
DROP EXTENSION hstore;
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


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: history_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_accounts (
    id bigint NOT NULL,
    address character varying(64)
);


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
    id bigint
);


--
-- Name: history_operation_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_operation_participants (
    id integer NOT NULL,
    history_operation_id bigint NOT NULL,
    history_account_id bigint NOT NULL
);


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_operation_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_operation_participants_id_seq OWNED BY history_operation_participants.id;


--
-- Name: history_operations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_operations (
    id bigint NOT NULL,
    transaction_id bigint NOT NULL,
    application_order integer NOT NULL,
    type integer NOT NULL,
    details jsonb
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
    result_code_s character varying NOT NULL,
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
    id bigint
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

ALTER TABLE ONLY history_operation_participants ALTER COLUMN id SET DEFAULT nextval('history_operation_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_participants ALTER COLUMN id SET DEFAULT nextval('history_transaction_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_statuses ALTER COLUMN id SET DEFAULT nextval('history_transaction_statuses_id_seq'::regclass);


--
-- Data for Name: history_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_accounts (id, address) FROM stdin;
0	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC
12884905984	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec
12884910080	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm
12884914176	g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw
12884918272	gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id) FROM stdin;
1	a9d12414d405652b752ce4425d3d94e7996a07a52228a58d7bf3bd35dd50eb46	\N	0	0	1970-01-01 00:00:00	2015-06-09 23:21:36.996975	2015-06-09 23:21:36.996975	4294967296
2	e0b69b1b944a45e19fca7c989b07ef51c28d22dd412dd6100f0e79526c4acba3	a9d12414d405652b752ce4425d3d94e7996a07a52228a58d7bf3bd35dd50eb46	0	0	2015-06-09 23:21:34	2015-06-09 23:21:37.006776	2015-06-09 23:21:37.006776	8589934592
3	099f758e22986d49bb78d93381efd50b11f5870d767174eb780a75b0421b30ca	e0b69b1b944a45e19fca7c989b07ef51c28d22dd412dd6100f0e79526c4acba3	0	0	2015-06-09 23:21:35	2015-06-09 23:21:37.016091	2015-06-09 23:21:37.016091	12884901888
4	783db0367bbbb16b8e5b6820c6d08bf59d1379267b71a4266c52e3a1762a0427	099f758e22986d49bb78d93381efd50b11f5870d767174eb780a75b0421b30ca	0	0	2015-06-09 23:21:36	2015-06-09 23:21:37.074106	2015-06-09 23:21:37.074106	17179869184
5	6c83bb9a674f522d69cd0f14c1ec438e4d9d7b72a57cbb7b442fac5de001b54b	783db0367bbbb16b8e5b6820c6d08bf59d1379267b71a4266c52e3a1762a0427	0	0	2015-06-09 23:21:37	2015-06-09 23:21:37.127324	2015-06-09 23:21:37.127324	21474836480
6	8fbe278e24b27d08b98123601d173e90c71bf65c2fd50cf7f367e5eb4c5cb193	6c83bb9a674f522d69cd0f14c1ec438e4d9d7b72a57cbb7b442fac5de001b54b	0	0	2015-06-09 23:21:38	2015-06-09 23:21:37.158036	2015-06-09 23:21:37.158036	25769803776
7	6bf73dbe57b658ed67403fae2452763b2d85a605fd4a032aaa6d8c311e496cdf	8fbe278e24b27d08b98123601d173e90c71bf65c2fd50cf7f367e5eb4c5cb193	0	0	2015-06-09 23:21:39	2015-06-09 23:21:37.189516	2015-06-09 23:21:37.189516	30064771072
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
115	12884905984	0
116	12884905984	12884905984
117	12884910080	0
118	12884910080	12884910080
119	12884914176	0
120	12884914176	12884914176
121	12884918272	0
122	12884918272	12884918272
123	17179873280	12884905984
124	17179877376	12884910080
125	17179881472	12884910080
126	17179885568	12884905984
127	21474840576	12884905984
128	21474840576	12884914176
129	21474844672	12884910080
130	21474844672	12884918272
131	25769807872	12884910080
132	25769811968	12884910080
133	25769816064	12884910080
134	30064775168	12884905984
135	30064779264	12884905984
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 135, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
12884905984	12884905984	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec", "starting_balance": 1000000000}
12884910080	12884910080	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm", "starting_balance": 1000000000}
12884914176	12884914176	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw", "starting_balance": 1000000000}
12884918272	12884918272	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD", "starting_balance": 1000000000}
17179873280	17179873280	0	6	{"limit": 9223372036854775807, "trustee": "g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw", "trustor": "gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec", "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw"}
17179877376	17179877376	0	6	{"limit": 9223372036854775807, "trustee": "g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw", "trustor": "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm", "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw"}
17179881472	17179881472	0	6	{"limit": 9223372036854775807, "trustee": "gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD", "trustor": "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm", "currency_code": "EUR", "currency_type": "alphanum", "currency_issuer": "gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD"}
17179885568	17179885568	0	6	{"limit": 9223372036854775807, "trustee": "gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD", "trustor": "gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec", "currency_code": "EUR", "currency_type": "alphanum", "currency_issuer": "gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD"}
21474840576	21474840576	0	1	{"to": "gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec", "from": "g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw", "amount": 5000000000, "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw"}
21474844672	21474844672	0	1	{"to": "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm", "from": "gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD", "amount": 5000000000, "currency_code": "EUR", "currency_type": "alphanum", "currency_issuer": "gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD"}
25769807872	25769807872	0	3	\N
25769811968	25769811968	0	3	\N
25769816064	25769816064	0	3	\N
30064775168	30064775168	0	3	\N
30064779264	30064779264	0	3	\N
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
106	8970cbcb8446206c1aace7d86015e2c5590e592284896af51e17e4532b4651d0	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	2015-06-09 23:21:37.021196	2015-06-09 23:21:37.021196
107	8970cbcb8446206c1aace7d86015e2c5590e592284896af51e17e4532b4651d0	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:37.022302	2015-06-09 23:21:37.022302
108	76fd495fadf894aaf76bb585d3f21311a6fb9d49dc76a0cb1a1dbae975317750	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	2015-06-09 23:21:37.033514	2015-06-09 23:21:37.033514
109	76fd495fadf894aaf76bb585d3f21311a6fb9d49dc76a0cb1a1dbae975317750	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:37.034507	2015-06-09 23:21:37.034507
110	628f63ebaaec6fc10afdc3f328652efda54673b4ce8d79cf4016620765d9ac18	g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw	2015-06-09 23:21:37.045606	2015-06-09 23:21:37.045606
111	628f63ebaaec6fc10afdc3f328652efda54673b4ce8d79cf4016620765d9ac18	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:37.046532	2015-06-09 23:21:37.046532
112	b649e64655fe54cd6ac97c1aa5450b81aace65b83b660d64a90a533ae2ba36cf	gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD	2015-06-09 23:21:37.05748	2015-06-09 23:21:37.05748
113	b649e64655fe54cd6ac97c1aa5450b81aace65b83b660d64a90a533ae2ba36cf	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:37.058521	2015-06-09 23:21:37.058521
114	a6e575fb041484e123afe7a758f35ba71b41f283c3c9dc1ebd5ada9baea45dec	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	2015-06-09 23:21:37.078625	2015-06-09 23:21:37.078625
115	750de3da9c03ab35901f5c2d947df9ca5c8e1bf6acddbeca29e87daaae61cdd6	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	2015-06-09 23:21:37.08719	2015-06-09 23:21:37.08719
116	9d65d7e3f8b5c61526379fbc0fa48468001a0692d79eab9ba1020d318ddad772	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	2015-06-09 23:21:37.097046	2015-06-09 23:21:37.097046
117	64f03f4c20cc81c8a21743d38dc50b9b32e0e3725b733be670b63455c8e0b815	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	2015-06-09 23:21:37.106427	2015-06-09 23:21:37.106427
118	cb51faa129a3e2f1f66dccc5e6762ee7b4caa3d8f3ff84135d000ab72959561d	g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw	2015-06-09 23:21:37.132059	2015-06-09 23:21:37.132059
119	fe8c1f698e2b442533f8cce840c6216c6e2b8ccf4f2a4ae23e00d6b6abe25ad2	gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD	2015-06-09 23:21:37.141322	2015-06-09 23:21:37.141322
120	2fa36c1876c50a4aabcea54e2a9e1913a09e5d141a34196cec9a04c0dd11c1a3	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	2015-06-09 23:21:37.162907	2015-06-09 23:21:37.162907
121	5eb5f3a1e76586d2f15c8c302d14b33136fece5d5fe4d73253a078870274fc3d	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	2015-06-09 23:21:37.170405	2015-06-09 23:21:37.170405
122	a6883a0a109e479de0cca966aa91b13ee9d140e583adf61ab309c799b4856673	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	2015-06-09 23:21:37.178162	2015-06-09 23:21:37.178162
123	9a40144a15fc2d15c545c03fe118e8b76451c312f6112710537b99ab56e60a76	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	2015-06-09 23:21:37.196092	2015-06-09 23:21:37.196092
124	451467fffee7ff53ca35e0c890f8de52699edc0ba212a074d9b6ce48be2c5e20	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	2015-06-09 23:21:37.20561	2015-06-09 23:21:37.20561
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 124, true);


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

COPY history_transactions (transaction_hash, ledger_sequence, application_order, account, account_sequence, max_fee, fee_paid, operation_count, transaction_status_id, created_at, updated_at, id) FROM stdin;
8970cbcb8446206c1aace7d86015e2c5590e592284896af51e17e4532b4651d0	3	1	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	1	10	10	1	-1	2015-06-09 23:21:37.019348	2015-06-09 23:21:37.019348	12884905984
76fd495fadf894aaf76bb585d3f21311a6fb9d49dc76a0cb1a1dbae975317750	3	2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2	10	10	1	-1	2015-06-09 23:21:37.031879	2015-06-09 23:21:37.031879	12884910080
628f63ebaaec6fc10afdc3f328652efda54673b4ce8d79cf4016620765d9ac18	3	3	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	3	10	10	1	-1	2015-06-09 23:21:37.044013	2015-06-09 23:21:37.044013	12884914176
b649e64655fe54cd6ac97c1aa5450b81aace65b83b660d64a90a533ae2ba36cf	3	4	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	4	10	10	1	-1	2015-06-09 23:21:37.055706	2015-06-09 23:21:37.055706	12884918272
a6e575fb041484e123afe7a758f35ba71b41f283c3c9dc1ebd5ada9baea45dec	4	1	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	12884901889	10	10	1	-1	2015-06-09 23:21:37.077031	2015-06-09 23:21:37.077031	17179873280
750de3da9c03ab35901f5c2d947df9ca5c8e1bf6acddbeca29e87daaae61cdd6	4	2	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	12884901889	10	10	1	-1	2015-06-09 23:21:37.085692	2015-06-09 23:21:37.085692	17179877376
9d65d7e3f8b5c61526379fbc0fa48468001a0692d79eab9ba1020d318ddad772	4	3	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	12884901890	10	10	1	-1	2015-06-09 23:21:37.094882	2015-06-09 23:21:37.094882	17179881472
64f03f4c20cc81c8a21743d38dc50b9b32e0e3725b733be670b63455c8e0b815	4	4	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	12884901890	10	10	1	-1	2015-06-09 23:21:37.104556	2015-06-09 23:21:37.104556	17179885568
cb51faa129a3e2f1f66dccc5e6762ee7b4caa3d8f3ff84135d000ab72959561d	5	1	g5rZSvzt7GarvaFbE8qurHfrRGr4rFrqBTsDzkA7dCKf619Hjw	12884901889	10	10	1	-1	2015-06-09 23:21:37.1305	2015-06-09 23:21:37.1305	21474840576
fe8c1f698e2b442533f8cce840c6216c6e2b8ccf4f2a4ae23e00d6b6abe25ad2	5	2	gsJY1dWBb89cC9Vk7Ad69Qc4YQoe5vXsUThFoq8jE2R5RXFCGUD	12884901889	10	10	1	-1	2015-06-09 23:21:37.139644	2015-06-09 23:21:37.139644	21474844672
2fa36c1876c50a4aabcea54e2a9e1913a09e5d141a34196cec9a04c0dd11c1a3	6	1	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	12884901891	10	10	1	-1	2015-06-09 23:21:37.161295	2015-06-09 23:21:37.161295	25769807872
5eb5f3a1e76586d2f15c8c302d14b33136fece5d5fe4d73253a078870274fc3d	6	2	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	12884901892	10	10	1	-1	2015-06-09 23:21:37.168542	2015-06-09 23:21:37.168542	25769811968
a6883a0a109e479de0cca966aa91b13ee9d140e583adf61ab309c799b4856673	6	3	gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm	12884901893	10	10	1	-1	2015-06-09 23:21:37.176334	2015-06-09 23:21:37.176334	25769816064
9a40144a15fc2d15c545c03fe118e8b76451c312f6112710537b99ab56e60a76	7	1	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	12884901891	10	10	1	-1	2015-06-09 23:21:37.193849	2015-06-09 23:21:37.193849	30064775168
451467fffee7ff53ca35e0c890f8de52699edc0ba212a074d9b6ce48be2c5e20	7	2	gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec	12884901892	10	10	1	-1	2015-06-09 23:21:37.203639	2015-06-09 23:21:37.203639	30064779264
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY schema_migrations (version) FROM stdin;
20150508215546
20150310224849
20150313225945
20150313225955
20150501160031
20150508003829
20150508175821
20150508183542
20150609230237
\.


--
-- Name: history_operation_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_operation_participants
    ADD CONSTRAINT history_operation_participants_pkey PRIMARY KEY (id);


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
-- Name: hist_op_p_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_op_p_id ON history_operation_participants USING btree (history_account_id, history_operation_id);


--
-- Name: hs_ledger_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_ledger_by_id ON history_ledgers USING btree (id);


--
-- Name: hs_transaction_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_transaction_by_id ON history_transactions USING btree (id);


--
-- Name: index_history_accounts_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_accounts_on_id ON history_accounts USING btree (id);


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
-- Name: index_history_operations_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_operations_on_id ON history_operations USING btree (id);


--
-- Name: index_history_operations_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_operations_on_transaction_id ON history_operations USING btree (transaction_id);


--
-- Name: index_history_operations_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_operations_on_type ON history_operations USING btree (type);


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

