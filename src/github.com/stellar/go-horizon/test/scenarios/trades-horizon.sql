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
DROP INDEX public.index_history_transactions_on_id;
DROP INDEX public.index_history_transaction_statuses_lc_on_all;
DROP INDEX public.index_history_transaction_participants_on_transaction_hash;
DROP INDEX public.index_history_transaction_participants_on_account;
DROP INDEX public.index_history_operations_on_type;
DROP INDEX public.index_history_operations_on_transaction_id;
DROP INDEX public.index_history_operations_on_id;
DROP INDEX public.index_history_ledgers_on_sequence;
DROP INDEX public.index_history_ledgers_on_previous_ledger_hash;
DROP INDEX public.index_history_ledgers_on_ledger_hash;
DROP INDEX public.index_history_ledgers_on_id;
DROP INDEX public.index_history_ledgers_on_closed_at;
DROP INDEX public.index_history_effects_on_type;
DROP INDEX public.index_history_accounts_on_id;
DROP INDEX public.hs_transaction_by_id;
DROP INDEX public.hs_ledger_by_id;
DROP INDEX public.hist_op_p_id;
DROP INDEX public.hist_e_id;
DROP INDEX public.hist_e_by_order;
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
DROP TABLE public.history_effects;
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
-- Name: history_effects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_effects (
    history_account_id bigint NOT NULL,
    history_operation_id bigint NOT NULL,
    "order" integer NOT NULL,
    type integer NOT NULL,
    details jsonb
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
0	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ
8589938688	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5
8589942784	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W
8589946880	GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ
8589950976	GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66
\.


--
-- Data for Name: history_effects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_effects (history_account_id, history_operation_id, "order", type, details) FROM stdin;
8589938688	8589938688	0	0	{"starting_balance": 1000000000}
0	8589938688	1	3	{"amount": 1000000000, "asset_type": "native"}
8589942784	8589942784	0	0	{"starting_balance": 1000000000}
0	8589942784	1	3	{"amount": 1000000000, "asset_type": "native"}
8589946880	8589946880	0	0	{"starting_balance": 1000000000}
0	8589946880	1	3	{"amount": 1000000000, "asset_type": "native"}
8589950976	8589950976	0	0	{"starting_balance": 1000000000}
0	8589950976	1	3	{"amount": 1000000000, "asset_type": "native"}
8589938688	17179873280	0	2	{"amount": 5000000000, "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ"}
8589946880	17179873280	1	3	{"amount": 5000000000, "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ"}
8589942784	17179877376	0	2	{"amount": 5000000000, "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66"}
8589950976	17179877376	1	3	{"amount": 5000000000, "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66"}
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id) FROM stdin;
1	e8e10918f9c000c73119abe54cf089f59f9015cc93c49ccf00b5e8b9afb6e6b1	\N	0	0	1970-01-01 00:00:00	2015-07-29 17:19:50.42806	2015-07-29 17:19:50.42806	4294967296
2	58043ee802446d4f890183c76d04c41dbf09c062fe1d0b9e7b64875490edff4c	e8e10918f9c000c73119abe54cf089f59f9015cc93c49ccf00b5e8b9afb6e6b1	4	4	2015-07-29 17:19:48	2015-07-29 17:19:50.438195	2015-07-29 17:19:50.438195	8589934592
3	ce21ac8471f90e3fee127fa750f8755acb3483c518c615db11a8be1e4abb8190	58043ee802446d4f890183c76d04c41dbf09c062fe1d0b9e7b64875490edff4c	4	4	2015-07-29 17:19:49	2015-07-29 17:19:50.54823	2015-07-29 17:19:50.54823	12884901888
4	c99546f0f4b1d0cc182e17a894f59c287300a8ed2c22250a2ebfb3c2f76b035e	ce21ac8471f90e3fee127fa750f8755acb3483c518c615db11a8be1e4abb8190	2	2	2015-07-29 17:19:50	2015-07-29 17:19:50.604059	2015-07-29 17:19:50.604059	17179869184
5	3fee86321d3a129cfb2843c0bb59eb26e177d9cf25c242b14c5203c511fd2d0a	c99546f0f4b1d0cc182e17a894f59c287300a8ed2c22250a2ebfb3c2f76b035e	3	3	2015-07-29 17:19:51	2015-07-29 17:19:50.654385	2015-07-29 17:19:50.654385	21474836480
6	58b790eb2adf962cff7da2aca4b84ef9cbd54d7d2b1bb505a919fcf59902257a	3fee86321d3a129cfb2843c0bb59eb26e177d9cf25c242b14c5203c511fd2d0a	2	2	2015-07-29 17:19:52	2015-07-29 17:19:50.695779	2015-07-29 17:19:50.695779	25769803776
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
156	8589938688	0
157	8589938688	8589938688
158	8589942784	0
159	8589942784	8589942784
160	8589946880	0
161	8589946880	8589946880
162	8589950976	0
163	8589950976	8589950976
164	12884905984	8589938688
165	12884910080	8589942784
166	12884914176	8589938688
167	12884918272	8589942784
168	17179873280	8589938688
169	17179873280	8589946880
170	17179877376	8589942784
171	17179877376	8589950976
172	21474840576	8589942784
173	21474844672	8589942784
174	21474848768	8589942784
175	25769807872	8589938688
176	25769811968	8589938688
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 176, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
8589938688	8589938688	0	0	{"funder": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ", "account": "GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5", "starting_balance": 1000000000}
8589942784	8589942784	0	0	{"funder": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ", "account": "GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W", "starting_balance": 1000000000}
8589946880	8589946880	0	0	{"funder": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ", "account": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ", "starting_balance": 1000000000}
8589950976	8589950976	0	0	{"funder": "GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ", "account": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66", "starting_balance": 1000000000}
12884905984	12884905984	0	6	{"limit": 9223372036854775807, "trustee": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ", "trustor": "GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ"}
12884910080	12884910080	0	6	{"limit": 9223372036854775807, "trustee": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ", "trustor": "GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ"}
12884914176	12884914176	0	6	{"limit": 9223372036854775807, "trustee": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66", "trustor": "GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66"}
12884918272	12884918272	0	6	{"limit": 9223372036854775807, "trustee": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66", "trustor": "GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66"}
17179873280	17179873280	0	1	{"to": "GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5", "from": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ", "amount": 5000000000, "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ"}
17179877376	17179877376	0	1	{"to": "GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W", "from": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66", "amount": 5000000000, "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66"}
21474840576	21474840576	0	3	{"price": {"d": 1, "n": 1}, "amount": 1000000000, "offer_id": 0}
21474844672	21474844672	0	3	{"price": {"d": 9, "n": 10}, "amount": 1111111111, "offer_id": 0}
21474848768	21474848768	0	3	{"price": {"d": 4, "n": 5}, "amount": 1250000000, "offer_id": 0}
25769807872	25769807872	0	3	{"price": {"d": 1, "n": 1}, "amount": 500000000, "offer_id": 0}
25769811968	25769811968	0	3	{"price": {"d": 1, "n": 1}, "amount": 500000000, "offer_id": 0}
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
138	590954e9b83abdba002380c8759e6dfb590efb9e00a670e5d08a34e854dd317f	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ	2015-07-29 17:19:50.444488	2015-07-29 17:19:50.444488
139	590954e9b83abdba002380c8759e6dfb590efb9e00a670e5d08a34e854dd317f	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	2015-07-29 17:19:50.445962	2015-07-29 17:19:50.445962
140	91b3082da2439c2d8cfeb14f971f9de28d077702869096b18ef0bf600646c1e0	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ	2015-07-29 17:19:50.470252	2015-07-29 17:19:50.470252
141	91b3082da2439c2d8cfeb14f971f9de28d077702869096b18ef0bf600646c1e0	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	2015-07-29 17:19:50.471811	2015-07-29 17:19:50.471811
142	e10eba6a3f7c6609bd484b388b92ed1af84c0b824530be54a170269b05f20301	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ	2015-07-29 17:19:50.494558	2015-07-29 17:19:50.494558
143	e10eba6a3f7c6609bd484b388b92ed1af84c0b824530be54a170269b05f20301	GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ	2015-07-29 17:19:50.495595	2015-07-29 17:19:50.495595
144	7480af2553c3a6741477ab131d2eaa63e54ebbca63c36b3093bd52472c0dc5d5	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ	2015-07-29 17:19:50.513267	2015-07-29 17:19:50.513267
145	7480af2553c3a6741477ab131d2eaa63e54ebbca63c36b3093bd52472c0dc5d5	GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66	2015-07-29 17:19:50.514448	2015-07-29 17:19:50.514448
146	b3dc1801ec177d18ffa6e5d5d7c7db1e09c293c210e983f47325607cd939ca64	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	2015-07-29 17:19:50.553664	2015-07-29 17:19:50.553664
147	7b9675daf1842502819af8002847376b80966d297ced152cc19f1f01a126dd3b	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	2015-07-29 17:19:50.563331	2015-07-29 17:19:50.563331
148	fb3654c1639e76bebfd4eb23a57e0008cbe54a9e2eb605f8dddc5d441661f84e	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	2015-07-29 17:19:50.573709	2015-07-29 17:19:50.573709
149	91db3ff560a4f8249463f3afa4c04027027fe56351c6e60c3e25049607ed6c55	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	2015-07-29 17:19:50.585578	2015-07-29 17:19:50.585578
150	40834c5ace8828e984964e551706fa651272c1a0d81ec8afdc950b6420b66951	GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ	2015-07-29 17:19:50.61012	2015-07-29 17:19:50.61012
151	5eb76c7ccf7fe2527c73bb45507361a880358b40f07d42931b279e563baaf157	GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66	2015-07-29 17:19:50.627367	2015-07-29 17:19:50.627367
152	669805776eb99b86f8ad5e5765c1ea3e8f2ead1b46bbcea49dff6b8ebbaa2dc1	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	2015-07-29 17:19:50.659464	2015-07-29 17:19:50.659464
153	abcf4368e41f126f9fdaec1e119dbad91d92f3a0d0b93902d167eb5df91bc785	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	2015-07-29 17:19:50.667592	2015-07-29 17:19:50.667592
154	a866490054544ee4ff6e09a1143673f4d3f580a6a50a923f0f3c531a24a2b527	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	2015-07-29 17:19:50.679143	2015-07-29 17:19:50.679143
155	04ac24bb5e8ee9085dcb614f35826df66ed8a4329898a9c4552c78cc1f546364	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	2015-07-29 17:19:50.702085	2015-07-29 17:19:50.702085
156	89c0cbc3d2c734a7902d4f522ea3bef3b015cfa469f1b573ece946430500205f	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	2015-07-29 17:19:50.710492	2015-07-29 17:19:50.710492
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 156, true);


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
590954e9b83abdba002380c8759e6dfb590efb9e00a670e5d08a34e854dd317f	2	1	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ	1	10	10	1	-1	2015-07-29 17:19:50.441447	2015-07-29 17:19:50.441447	8589938688
91b3082da2439c2d8cfeb14f971f9de28d077702869096b18ef0bf600646c1e0	2	2	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ	2	10	10	1	-1	2015-07-29 17:19:50.46637	2015-07-29 17:19:50.46637	8589942784
e10eba6a3f7c6609bd484b388b92ed1af84c0b824530be54a170269b05f20301	2	3	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ	3	10	10	1	-1	2015-07-29 17:19:50.492444	2015-07-29 17:19:50.492444	8589946880
7480af2553c3a6741477ab131d2eaa63e54ebbca63c36b3093bd52472c0dc5d5	2	4	GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ	4	10	10	1	-1	2015-07-29 17:19:50.510665	2015-07-29 17:19:50.510665	8589950976
b3dc1801ec177d18ffa6e5d5d7c7db1e09c293c210e983f47325607cd939ca64	3	1	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	8589934593	10	10	1	-1	2015-07-29 17:19:50.551764	2015-07-29 17:19:50.551764	12884905984
7b9675daf1842502819af8002847376b80966d297ced152cc19f1f01a126dd3b	3	2	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	8589934593	10	10	1	-1	2015-07-29 17:19:50.561529	2015-07-29 17:19:50.561529	12884910080
fb3654c1639e76bebfd4eb23a57e0008cbe54a9e2eb605f8dddc5d441661f84e	3	3	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	8589934594	10	10	1	-1	2015-07-29 17:19:50.571762	2015-07-29 17:19:50.571762	12884914176
91db3ff560a4f8249463f3afa4c04027027fe56351c6e60c3e25049607ed6c55	3	4	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	8589934594	10	10	1	-1	2015-07-29 17:19:50.582997	2015-07-29 17:19:50.582997	12884918272
40834c5ace8828e984964e551706fa651272c1a0d81ec8afdc950b6420b66951	4	1	GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ	8589934593	10	10	1	-1	2015-07-29 17:19:50.60816	2015-07-29 17:19:50.60816	17179873280
5eb76c7ccf7fe2527c73bb45507361a880358b40f07d42931b279e563baaf157	4	2	GDYPTITNS7MRHWDRUEV7R5QIX522Q6UDLQMGSIKXY5JEZHXJR47UOF66	8589934593	10	10	1	-1	2015-07-29 17:19:50.624924	2015-07-29 17:19:50.624924	17179877376
669805776eb99b86f8ad5e5765c1ea3e8f2ead1b46bbcea49dff6b8ebbaa2dc1	5	1	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	8589934595	10	10	1	-1	2015-07-29 17:19:50.657551	2015-07-29 17:19:50.657551	21474840576
abcf4368e41f126f9fdaec1e119dbad91d92f3a0d0b93902d167eb5df91bc785	5	2	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	8589934596	10	10	1	-1	2015-07-29 17:19:50.665785	2015-07-29 17:19:50.665785	21474844672
a866490054544ee4ff6e09a1143673f4d3f580a6a50a923f0f3c531a24a2b527	5	3	GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W	8589934597	10	10	1	-1	2015-07-29 17:19:50.676173	2015-07-29 17:19:50.676173	21474848768
04ac24bb5e8ee9085dcb614f35826df66ed8a4329898a9c4552c78cc1f546364	6	1	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	8589934595	10	10	1	-1	2015-07-29 17:19:50.699783	2015-07-29 17:19:50.699783	25769807872
89c0cbc3d2c734a7902d4f522ea3bef3b015cfa469f1b573ece946430500205f	6	2	GA4WKBJM5IA2IPHLGJUI5LQHVAYRPMF7UEU57LFELTFQMR5PNTKMU5L5	8589934596	10	10	1	-1	2015-07-29 17:19:50.708386	2015-07-29 17:19:50.708386	25769811968
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
20150629181921
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
-- Name: hist_e_by_order; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_e_by_order ON history_effects USING btree (history_operation_id, "order");


--
-- Name: hist_e_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_e_id ON history_effects USING btree (history_account_id, history_operation_id, "order");


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
-- Name: index_history_effects_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_effects_on_type ON history_effects USING btree (type);


--
-- Name: index_history_ledgers_on_closed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_ledgers_on_closed_at ON history_ledgers USING btree (closed_at);


--
-- Name: index_history_ledgers_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_id ON history_ledgers USING btree (id);


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
-- Name: index_history_transactions_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_transactions_on_id ON history_transactions USING btree (id);


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

