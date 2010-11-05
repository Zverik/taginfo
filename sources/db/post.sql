--
--  Taginfo source: Database
--
--  post.sql
--

.bail ON

PRAGMA journal_mode  = OFF;
PRAGMA synchronous   = OFF;
PRAGMA count_changes = OFF;
PRAGMA temp_store    = MEMORY;
PRAGMA cache_size    = 5000000; 

ATTACH DATABASE '__DIR__/count.db' AS count;
INSERT INTO stats SELECT * FROM count.stats;
DETACH DATABASE count;

CREATE UNIQUE INDEX keys_key_idx ON keys (key);
CREATE        INDEX tags_key_idx ON tags (key);
-- CREATE UNIQUE INDEX tags_key_value_idx ON tags (key, value);
CREATE        INDEX keypairs_key1_idx ON keypairs (key1);
CREATE        INDEX keypairs_key2_idx ON keypairs (key2);
CREATE UNIQUE INDEX key_distributions_key_idx ON key_distributions (key);

INSERT INTO stats (key, value) SELECT 'num_keys',                  count(*) FROM keys;
INSERT INTO stats (key, value) SELECT 'num_keys_on_nodes',         count(*) FROM keys WHERE count_nodes     > 0;
INSERT INTO stats (key, value) SELECT 'num_keys_on_ways',          count(*) FROM keys WHERE count_ways      > 0;
INSERT INTO stats (key, value) SELECT 'num_keys_on_relations',     count(*) FROM keys WHERE count_relations > 0;

INSERT INTO stats (key, value) SELECT 'num_tags',                  count(*) FROM tags;
INSERT INTO stats (key, value) SELECT 'num_tags_on_nodes',         count(*) FROM tags WHERE count_nodes     > 0;
INSERT INTO stats (key, value) SELECT 'num_tags_on_ways',          count(*) FROM tags WHERE count_ways      > 0;
INSERT INTO stats (key, value) SELECT 'num_tags_on_relations',     count(*) FROM tags WHERE count_relations > 0;

INSERT INTO stats (key, value) SELECT 'num_keypairs',              count(*) FROM keypairs;
INSERT INTO stats (key, value) SELECT 'num_keypairs_on_nodes',     count(*) FROM keypairs WHERE count_nodes     > 0;
INSERT INTO stats (key, value) SELECT 'num_keypairs_on_ways',      count(*) FROM keypairs WHERE count_ways      > 0;
INSERT INTO stats (key, value) SELECT 'num_keypairs_on_relations', count(*) FROM keypairs WHERE count_relations > 0;

INSERT INTO stats (key, value) SELECT 'characters_in_keys_plain',   count(*) FROM keys WHERE characters='plain';
INSERT INTO stats (key, value) SELECT 'characters_in_keys_colon',   count(*) FROM keys WHERE characters='colon';
INSERT INTO stats (key, value) SELECT 'characters_in_keys_letters', count(*) FROM keys WHERE characters='letters';
INSERT INTO stats (key, value) SELECT 'characters_in_keys_space',   count(*) FROM keys WHERE characters='space';
INSERT INTO stats (key, value) SELECT 'characters_in_keys_problem', count(*) FROM keys WHERE characters='problem';
INSERT INTO stats (key, value) SELECT 'characters_in_keys_rest',    count(*) FROM keys WHERE characters='rest';

UPDATE keys SET prevalent_values=(
        SELECT group_concat(value, '|') FROM (
            SELECT value FROM tags t
                    WHERE t.key       = keys.key
                      AND t.count_all > keys.count_all / 100
                 ORDER BY t.count_all DESC
                    LIMIT 10
               
        )
    ) WHERE values_all < 1000;

ANALYZE;

UPDATE meta SET update_end=datetime('now');
