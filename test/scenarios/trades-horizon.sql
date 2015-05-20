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
    details hstore
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
12884905984	gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1
12884910080	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ
12884914176	g1wq85ptB1XAWvfc9W2YueF72zojjXyywPjfGc5xkXwHx5Dsjg
12884918272	gsSW46BD1WdoyqSoope84Hq1euVuaFe3JPnr5cy4kcYVtAKyk1r
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id) FROM stdin;
1	41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	\N	0	0	1970-01-01 00:00:00	2015-05-20 20:44:25.56903	2015-05-20 20:44:25.56903	4294967296
2	a2433be82b17adf187f62c8ec7c7ff518a741b8e25b5c20ad8bbe1a408e0bb6d	41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	0	0	2015-05-20 20:44:24	2015-05-20 20:44:25.578513	2015-05-20 20:44:25.578513	8589934592
3	4d10758bc212a36a02ee72f52df803a2b8284750006a5e40c419d2c39e9da89b	a2433be82b17adf187f62c8ec7c7ff518a741b8e25b5c20ad8bbe1a408e0bb6d	0	0	2015-05-20 20:44:25	2015-05-20 20:44:25.588307	2015-05-20 20:44:25.588307	12884901888
4	066bce300e7c1c55023a764188be88ce0dc5d580a855160d5716e2412eeb8cca	4d10758bc212a36a02ee72f52df803a2b8284750006a5e40c419d2c39e9da89b	0	0	2015-05-20 20:44:26	2015-05-20 20:44:25.651821	2015-05-20 20:44:25.651821	17179869184
5	231d5ae6153eff2261927af8bd724faca870245dda0cb11b8f523e407c2dd9b6	066bce300e7c1c55023a764188be88ce0dc5d580a855160d5716e2412eeb8cca	0	0	2015-05-20 20:44:27	2015-05-20 20:44:25.690935	2015-05-20 20:44:25.690935	21474836480
6	4614926f3654bb3c94acd94024f6a9c6935c6589e0d3bcc3562e2491fe87ad05	231d5ae6153eff2261927af8bd724faca870245dda0cb11b8f523e407c2dd9b6	0	0	2015-05-20 20:44:28	2015-05-20 20:44:25.715448	2015-05-20 20:44:25.715448	25769803776
7	0141daa5f2d92e481bc37c77d2fe863f09ff2a943efef3f22d8cd91064c9045d	4614926f3654bb3c94acd94024f6a9c6935c6589e0d3bcc3562e2491fe87ad05	0	0	2015-05-20 20:44:29	2015-05-20 20:44:25.742743	2015-05-20 20:44:25.742743	30064771072
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
154	12884905984	0
155	12884905984	12884905984
156	12884910080	0
157	12884910080	12884910080
158	12884914176	0
159	12884914176	12884914176
160	12884918272	0
161	12884918272	12884918272
162	17179873280	12884905984
163	17179877376	12884910080
164	17179881472	12884905984
165	17179885568	12884910080
166	21474840576	12884905984
167	21474840576	12884914176
168	21474844672	12884910080
169	21474844672	12884918272
170	25769807872	12884910080
171	25769811968	12884910080
172	25769816064	12884910080
173	30064775168	12884905984
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 173, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
12884905984	12884905984	0	0	"funder"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account"=>"gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1", "starting_balance"=>"1000000000"
12884910080	12884910080	0	0	"funder"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account"=>"gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ", "starting_balance"=>"1000000000"
12884914176	12884914176	0	0	"funder"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account"=>"g1wq85ptB1XAWvfc9W2YueF72zojjXyywPjfGc5xkXwHx5Dsjg", "starting_balance"=>"1000000000"
12884918272	12884918272	0	0	"funder"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account"=>"gsSW46BD1WdoyqSoope84Hq1euVuaFe3JPnr5cy4kcYVtAKyk1r", "starting_balance"=>"1000000000"
17179873280	17179873280	0	5	\N
17179877376	17179877376	0	5	\N
17179881472	17179881472	0	5	\N
17179885568	17179885568	0	5	\N
21474840576	21474840576	0	1	"to"=>"gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1", "from"=>"g1wq85ptB1XAWvfc9W2YueF72zojjXyywPjfGc5xkXwHx5Dsjg", "amount"=>"5000000000", "currency_code"=>"USD", "currency_issuer"=>"g1wq85ptB1XAWvfc9W2YueF72zojjXyywPjfGc5xkXwHx5Dsjg"
21474844672	21474844672	0	1	"to"=>"gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ", "from"=>"gsSW46BD1WdoyqSoope84Hq1euVuaFe3JPnr5cy4kcYVtAKyk1r", "amount"=>"5000000000", "currency_code"=>"EUR", "currency_issuer"=>"gsSW46BD1WdoyqSoope84Hq1euVuaFe3JPnr5cy4kcYVtAKyk1r"
25769807872	25769807872	0	3	\N
25769811968	25769811968	0	3	\N
25769816064	25769816064	0	3	\N
30064775168	30064775168	0	3	\N
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
148	3eb5812ecd85b91987f28130e223f54e18313376fa6ea7ea2238859d05b7cb07	gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1	2015-05-20 20:44:25.595276	2015-05-20 20:44:25.595276
149	3eb5812ecd85b91987f28130e223f54e18313376fa6ea7ea2238859d05b7cb07	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-20 20:44:25.596947	2015-05-20 20:44:25.596947
150	c1490f14d57cede8adca96cd8d7dae279949f32797bbf8a707043bb03c797907	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	2015-05-20 20:44:25.610197	2015-05-20 20:44:25.610197
151	c1490f14d57cede8adca96cd8d7dae279949f32797bbf8a707043bb03c797907	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-20 20:44:25.61116	2015-05-20 20:44:25.61116
152	0e99f8a673150fefc1bd43e74fd205a2052020902a4b43fc6d6cb5b6ca2497f6	g1wq85ptB1XAWvfc9W2YueF72zojjXyywPjfGc5xkXwHx5Dsjg	2015-05-20 20:44:25.622265	2015-05-20 20:44:25.622265
153	0e99f8a673150fefc1bd43e74fd205a2052020902a4b43fc6d6cb5b6ca2497f6	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-20 20:44:25.623263	2015-05-20 20:44:25.623263
154	49731903add69957a5458edd0ce197ed9bb167ea89b3597639225046230ab7db	gsSW46BD1WdoyqSoope84Hq1euVuaFe3JPnr5cy4kcYVtAKyk1r	2015-05-20 20:44:25.634215	2015-05-20 20:44:25.634215
155	49731903add69957a5458edd0ce197ed9bb167ea89b3597639225046230ab7db	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-20 20:44:25.635186	2015-05-20 20:44:25.635186
156	da1ed8314b62b9d011b309ea93145eb35cf9227295b98f087e69067553373a7a	gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1	2015-05-20 20:44:25.656414	2015-05-20 20:44:25.656414
157	4ecae9cba4864aa1cab96ef145b2d2238b6b88c27f50221ac10dc35ba7982d0b	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	2015-05-20 20:44:25.664974	2015-05-20 20:44:25.664974
158	01317c5cff4235b60e0a1752c8c20fccedd59b775a308928f3b3d59d4655a6ca	gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1	2015-05-20 20:44:25.672602	2015-05-20 20:44:25.672602
159	df722b8a170aa6279c26aee62527fb2ee06a2dae40efd1a1128e1c7f4b896c33	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	2015-05-20 20:44:25.679349	2015-05-20 20:44:25.679349
160	3e93d934d1d7efd54a3dfd397ac5013110047280b3bb11a1e12b247a8093eb55	g1wq85ptB1XAWvfc9W2YueF72zojjXyywPjfGc5xkXwHx5Dsjg	2015-05-20 20:44:25.695555	2015-05-20 20:44:25.695555
161	fc72ebd40e1a2877ab73453237de4cf778b3d26dd726d805eabd69785010cf97	gsSW46BD1WdoyqSoope84Hq1euVuaFe3JPnr5cy4kcYVtAKyk1r	2015-05-20 20:44:25.703194	2015-05-20 20:44:25.703194
162	e3d876c941d508763d40d721b406f28bf8a575a4c9e50cf46e6532c69d3bb1b5	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	2015-05-20 20:44:25.71951	2015-05-20 20:44:25.71951
163	da1fc20a28331866a5025eefff03c4fa8fd59a3ceb18478245e7c96b1ce8416d	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	2015-05-20 20:44:25.725842	2015-05-20 20:44:25.725842
164	f442c54284af7739d4e99e642b55143cd489d2a83d18ebb152e4b2c5c0f564f2	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	2015-05-20 20:44:25.73197	2015-05-20 20:44:25.73197
165	fcb02d24660d136b3a70bade58bf3609245af7322a70fa8aaa541cb32f731e31	gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1	2015-05-20 20:44:25.74703	2015-05-20 20:44:25.74703
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 165, true);


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
3eb5812ecd85b91987f28130e223f54e18313376fa6ea7ea2238859d05b7cb07	3	1	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	1	10	10	1	-1	2015-05-20 20:44:25.59232	2015-05-20 20:44:25.59232	12884905984
c1490f14d57cede8adca96cd8d7dae279949f32797bbf8a707043bb03c797907	3	2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2	10	10	1	-1	2015-05-20 20:44:25.608414	2015-05-20 20:44:25.608414	12884910080
0e99f8a673150fefc1bd43e74fd205a2052020902a4b43fc6d6cb5b6ca2497f6	3	3	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	3	10	10	1	-1	2015-05-20 20:44:25.620616	2015-05-20 20:44:25.620616	12884914176
49731903add69957a5458edd0ce197ed9bb167ea89b3597639225046230ab7db	3	4	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	4	10	10	1	-1	2015-05-20 20:44:25.632523	2015-05-20 20:44:25.632523	12884918272
da1ed8314b62b9d011b309ea93145eb35cf9227295b98f087e69067553373a7a	4	1	gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1	12884901889	10	10	1	-1	2015-05-20 20:44:25.654742	2015-05-20 20:44:25.654742	17179873280
4ecae9cba4864aa1cab96ef145b2d2238b6b88c27f50221ac10dc35ba7982d0b	4	2	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	12884901889	10	10	1	-1	2015-05-20 20:44:25.663319	2015-05-20 20:44:25.663319	17179877376
01317c5cff4235b60e0a1752c8c20fccedd59b775a308928f3b3d59d4655a6ca	4	3	gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1	12884901890	10	10	1	-1	2015-05-20 20:44:25.670765	2015-05-20 20:44:25.670765	17179881472
df722b8a170aa6279c26aee62527fb2ee06a2dae40efd1a1128e1c7f4b896c33	4	4	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	12884901890	10	10	1	-1	2015-05-20 20:44:25.67785	2015-05-20 20:44:25.67785	17179885568
3e93d934d1d7efd54a3dfd397ac5013110047280b3bb11a1e12b247a8093eb55	5	1	g1wq85ptB1XAWvfc9W2YueF72zojjXyywPjfGc5xkXwHx5Dsjg	12884901889	10	10	1	-1	2015-05-20 20:44:25.693909	2015-05-20 20:44:25.693909	21474840576
fc72ebd40e1a2877ab73453237de4cf778b3d26dd726d805eabd69785010cf97	5	2	gsSW46BD1WdoyqSoope84Hq1euVuaFe3JPnr5cy4kcYVtAKyk1r	12884901889	10	10	1	-1	2015-05-20 20:44:25.701835	2015-05-20 20:44:25.701835	21474844672
e3d876c941d508763d40d721b406f28bf8a575a4c9e50cf46e6532c69d3bb1b5	6	1	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	12884901891	10	10	1	-1	2015-05-20 20:44:25.718195	2015-05-20 20:44:25.718195	25769807872
da1fc20a28331866a5025eefff03c4fa8fd59a3ceb18478245e7c96b1ce8416d	6	2	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	12884901892	10	10	1	-1	2015-05-20 20:44:25.72453	2015-05-20 20:44:25.72453	25769811968
f442c54284af7739d4e99e642b55143cd489d2a83d18ebb152e4b2c5c0f564f2	6	3	gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ	12884901893	10	10	1	-1	2015-05-20 20:44:25.730682	2015-05-20 20:44:25.730682	25769816064
fcb02d24660d136b3a70bade58bf3609245af7322a70fa8aaa541cb32f731e31	7	1	gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1	12884901891	10	10	1	-1	2015-05-20 20:44:25.745486	2015-05-20 20:44:25.745486	30064775168
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

