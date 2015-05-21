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
12884905984	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp
12884910080	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK
12884914176	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3
12884918272	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id) FROM stdin;
1	41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	\N	0	0	1970-01-01 00:00:00	2015-05-21 15:39:00.707655	2015-05-21 15:39:00.707655	4294967296
2	6ddab1486dd944e4a374caf9a40a460416638e1578e3f17482acfd289c5cb847	41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	0	0	2015-05-21 15:38:59	2015-05-21 15:39:00.71794	2015-05-21 15:39:00.71794	8589934592
3	c86af9e44867edb1580a0debc372353085f016f4754efef8fd003ba1a74bce3a	6ddab1486dd944e4a374caf9a40a460416638e1578e3f17482acfd289c5cb847	0	0	2015-05-21 15:39:00	2015-05-21 15:39:00.728702	2015-05-21 15:39:00.728702	12884901888
4	f8b99b568ece0b2d7e83b515ea8b5a26fb771f873022c4e6477c9b6648f89e70	c86af9e44867edb1580a0debc372353085f016f4754efef8fd003ba1a74bce3a	0	0	2015-05-21 15:39:01	2015-05-21 15:39:00.792195	2015-05-21 15:39:00.792195	17179869184
5	bdf3b040dae334bbdacc926943ddcc20b6ec83bbd94541f5e79f7f9d2ae1d379	f8b99b568ece0b2d7e83b515ea8b5a26fb771f873022c4e6477c9b6648f89e70	0	0	2015-05-21 15:39:02	2015-05-21 15:39:00.831365	2015-05-21 15:39:00.831365	21474836480
6	ac0d829180cb3c9b648f384ac994e9b6611cd983d87a1b53ec3a4e42a8ef98f2	bdf3b040dae334bbdacc926943ddcc20b6ec83bbd94541f5e79f7f9d2ae1d379	0	0	2015-05-21 15:39:03	2015-05-21 15:39:00.856063	2015-05-21 15:39:00.856063	25769803776
7	6bbe40d7fcca5d55b59d0ad2c3a6e972a7ea1761602cc52160c09592ca0e395a	ac0d829180cb3c9b648f384ac994e9b6611cd983d87a1b53ec3a4e42a8ef98f2	0	0	2015-05-21 15:39:04	2015-05-21 15:39:00.885543	2015-05-21 15:39:00.885543	30064771072
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
71	12884905984	0
72	12884905984	12884905984
73	12884910080	0
74	12884910080	12884910080
75	12884914176	0
76	12884914176	12884914176
77	12884918272	0
78	12884918272	12884918272
79	17179873280	12884905984
80	17179877376	12884910080
81	17179881472	12884910080
82	17179885568	12884905984
83	21474840576	12884905984
84	21474840576	12884914176
85	21474844672	12884910080
86	21474844672	12884918272
87	25769807872	12884910080
88	25769811968	12884910080
89	25769816064	12884910080
90	30064775168	12884905984
91	30064779264	12884905984
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 91, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
12884905984	12884905984	0	0	"funder"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account"=>"gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp", "starting_balance"=>"1000000000"
12884910080	12884910080	0	0	"funder"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account"=>"gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK", "starting_balance"=>"1000000000"
12884914176	12884914176	0	0	"funder"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account"=>"gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3", "starting_balance"=>"1000000000"
12884918272	12884918272	0	0	"funder"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account"=>"gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk", "starting_balance"=>"1000000000"
17179873280	17179873280	0	5	\N
17179877376	17179877376	0	5	\N
17179881472	17179881472	0	5	\N
17179885568	17179885568	0	5	\N
21474840576	21474840576	0	1	"to"=>"gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp", "from"=>"gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3", "amount"=>"5000000000", "currency_code"=>"USD", "currency_type"=>"alphanum", "currency_issuer"=>"gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3"
21474844672	21474844672	0	1	"to"=>"gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK", "from"=>"gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk", "amount"=>"5000000000", "currency_code"=>"EUR", "currency_type"=>"alphanum", "currency_issuer"=>"gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk"
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
74	663b58919ee418808c37a22d28ef64cda597595d14c40d7d8609f339af7b8259	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	2015-05-21 15:39:00.734426	2015-05-21 15:39:00.734426
75	663b58919ee418808c37a22d28ef64cda597595d14c40d7d8609f339af7b8259	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-21 15:39:00.735842	2015-05-21 15:39:00.735842
76	8a1ca0b7cdbe8306dd6c21d4be55401fca61f575361c2feed152aa2c5c949196	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	2015-05-21 15:39:00.749041	2015-05-21 15:39:00.749041
77	8a1ca0b7cdbe8306dd6c21d4be55401fca61f575361c2feed152aa2c5c949196	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-21 15:39:00.75008	2015-05-21 15:39:00.75008
78	28204d3b1e2fe7a2bceb2832cd3e2030e9f3b7e5cd5d1ee3b7228c057c341eaa	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	2015-05-21 15:39:00.761522	2015-05-21 15:39:00.761522
79	28204d3b1e2fe7a2bceb2832cd3e2030e9f3b7e5cd5d1ee3b7228c057c341eaa	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-21 15:39:00.762693	2015-05-21 15:39:00.762693
80	ce7df370cae7443cb8114480fc80b1f6d3240abe1bfcd0344169cf289ec7ce12	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	2015-05-21 15:39:00.774675	2015-05-21 15:39:00.774675
81	ce7df370cae7443cb8114480fc80b1f6d3240abe1bfcd0344169cf289ec7ce12	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-21 15:39:00.775669	2015-05-21 15:39:00.775669
82	140f1354fd827369d2c5b246cf8a24289d8d99c5d4455423884db5be9e95208e	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	2015-05-21 15:39:00.796949	2015-05-21 15:39:00.796949
83	9f2bc7cef164391b7172a7b709fc28944a559682a784bba1c0351dfb115fcf57	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	2015-05-21 15:39:00.804914	2015-05-21 15:39:00.804914
84	e5463115c134f01598fa417ebdaa841d53b753b15981943e373b303348ed13f8	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	2015-05-21 15:39:00.812223	2015-05-21 15:39:00.812223
85	426c6232f0c741c940a26660c91f8327bce2f0b17e498ff33d3a6f3c1e43c99a	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	2015-05-21 15:39:00.819665	2015-05-21 15:39:00.819665
86	82704f676ca50edb945c7074e6b7d795e13d0b4e5aac7263a54b4cf0eaa54131	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	2015-05-21 15:39:00.83564	2015-05-21 15:39:00.83564
87	8f69a0c3788d8d5340339e69fa9361259b19caaf62b71b2bbe6aadc02bd4e555	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	2015-05-21 15:39:00.843356	2015-05-21 15:39:00.843356
88	7d71c628e9e38b3abaa3c14e78080b4283431c6c357cc8a39436bb2358596b64	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	2015-05-21 15:39:00.860422	2015-05-21 15:39:00.860422
89	82a78dadeb868eb727971fba96a6e1ca3c3f1b607b8ba643551d16454e294baf	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	2015-05-21 15:39:00.867354	2015-05-21 15:39:00.867354
90	c915062e56d23bd8725ca98eefa135848f35103a918bfcad20928fcc429a20c9	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	2015-05-21 15:39:00.873787	2015-05-21 15:39:00.873787
91	9a01a4460c6581e53d8bb4966ace81ca60fa4d12d51b75007ba1c0abe6f2c484	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	2015-05-21 15:39:00.889869	2015-05-21 15:39:00.889869
92	ae0bc00fddbd117b9786f4a8ce2e1bb506aa7401a29778f8fc23c013498318df	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	2015-05-21 15:39:00.897726	2015-05-21 15:39:00.897726
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 92, true);


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
663b58919ee418808c37a22d28ef64cda597595d14c40d7d8609f339af7b8259	3	1	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	1	10	10	1	-1	2015-05-21 15:39:00.732231	2015-05-21 15:39:00.732231	12884905984
8a1ca0b7cdbe8306dd6c21d4be55401fca61f575361c2feed152aa2c5c949196	3	2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2	10	10	1	-1	2015-05-21 15:39:00.747179	2015-05-21 15:39:00.747179	12884910080
28204d3b1e2fe7a2bceb2832cd3e2030e9f3b7e5cd5d1ee3b7228c057c341eaa	3	3	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	3	10	10	1	-1	2015-05-21 15:39:00.759419	2015-05-21 15:39:00.759419	12884914176
ce7df370cae7443cb8114480fc80b1f6d3240abe1bfcd0344169cf289ec7ce12	3	4	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	4	10	10	1	-1	2015-05-21 15:39:00.772738	2015-05-21 15:39:00.772738	12884918272
140f1354fd827369d2c5b246cf8a24289d8d99c5d4455423884db5be9e95208e	4	1	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	12884901889	10	10	1	-1	2015-05-21 15:39:00.795424	2015-05-21 15:39:00.795424	17179873280
9f2bc7cef164391b7172a7b709fc28944a559682a784bba1c0351dfb115fcf57	4	2	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	12884901889	10	10	1	-1	2015-05-21 15:39:00.803296	2015-05-21 15:39:00.803296	17179877376
e5463115c134f01598fa417ebdaa841d53b753b15981943e373b303348ed13f8	4	3	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	12884901890	10	10	1	-1	2015-05-21 15:39:00.810533	2015-05-21 15:39:00.810533	17179881472
426c6232f0c741c940a26660c91f8327bce2f0b17e498ff33d3a6f3c1e43c99a	4	4	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	12884901890	10	10	1	-1	2015-05-21 15:39:00.817999	2015-05-21 15:39:00.817999	17179885568
82704f676ca50edb945c7074e6b7d795e13d0b4e5aac7263a54b4cf0eaa54131	5	1	gsAEUu17cGykMsvKz4n7qZ4AHbG1ACMvTJ8SMpExqQtRViy9nA3	12884901889	10	10	1	-1	2015-05-21 15:39:00.834201	2015-05-21 15:39:00.834201	21474840576
8f69a0c3788d8d5340339e69fa9361259b19caaf62b71b2bbe6aadc02bd4e555	5	2	gYGZV1TercYFP2Fd8tstXt2NaamJwUeUU92m3xwsrC3YxbBaBk	12884901889	10	10	1	-1	2015-05-21 15:39:00.842006	2015-05-21 15:39:00.842006	21474844672
7d71c628e9e38b3abaa3c14e78080b4283431c6c357cc8a39436bb2358596b64	6	1	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	12884901891	10	10	1	-1	2015-05-21 15:39:00.858938	2015-05-21 15:39:00.858938	25769807872
82a78dadeb868eb727971fba96a6e1ca3c3f1b607b8ba643551d16454e294baf	6	2	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	12884901892	10	10	1	-1	2015-05-21 15:39:00.865871	2015-05-21 15:39:00.865871	25769811968
c915062e56d23bd8725ca98eefa135848f35103a918bfcad20928fcc429a20c9	6	3	gspJcyDmF2LSdkD2CsT9vjfUq4orYaxXheGT3a7shNkWBC3qnrK	12884901893	10	10	1	-1	2015-05-21 15:39:00.872508	2015-05-21 15:39:00.872508	25769816064
9a01a4460c6581e53d8bb4966ace81ca60fa4d12d51b75007ba1c0abe6f2c484	7	1	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	12884901891	10	10	1	-1	2015-05-21 15:39:00.888321	2015-05-21 15:39:00.888321	30064775168
ae0bc00fddbd117b9786f4a8ce2e1bb506aa7401a29778f8fc23c013498318df	7	2	gs8aFMpjzZAYyQrytPj59aAq3UbVFXkHiWpSo3KjE59fR2DVxyp	12884901892	10	10	1	-1	2015-05-21 15:39:00.89626	2015-05-21 15:39:00.89626	30064779264
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

