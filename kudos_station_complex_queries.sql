-- Kaan's Query: Shows the users who works in the given department and get all variation of the kudoses.

SELECT U.username
FROM "user" AS U
WHERE U.username IN (
    SELECT U.username
    FROM "user" AS U,
         department AS D,
         works_in AS WI
    WHERE U.user_id = WI.user_id
      AND D.department_id = WI.department_id
      AND D.department_name = ?1
)
  AND U.username IN (
    SELECT kudos_data_of_users.recipient_username
    FROM (SELECT K.recipient_username, COUNT(DISTINCT KV.kudos_variation_id) AS total_count
          FROM kudos AS K,
               kudos_variation AS KV,
               has_variation AS HV
          WHERE K.kudos_id = HV.kudos_id
            AND KV.kudos_variation_id = HV.kudos_variation_id
          GROUP BY K.recipient_username) AS kudos_data_of_users
    WHERE kudos_data_of_users.total_count = (SELECT COUNT(DISTINCT KV.kudos_variation_id) FROM kudos_variation AS KV))
LIMIT 3;

-- Can's Query: Shows the last 3 recent kudoses that are owned by users who work in all projects run by the given department.

SELECT *
FROM kudos AS k
WHERE k.recipient_username IN (SELECT u.username
                               FROM "user" AS u,
                                    department AS d
                               WHERE d.department_name = ?1
                                 AND NOT EXISTS(SELECT p.project_id
                                                FROM project AS p
                                                WHERE p.department_id = d.department_id
                                                EXCEPT
                                                (SELECT wo.project_id
                                                 FROM works_on AS wo
                                                 WHERE u.user_id = wo.user_id)))
ORDER BY created_at DESC
LIMIT 3;

-- Omer's Query: Shows users who has sent at least 2 given kudoses, but has not sent more than 10.

SELECT u.username
FROM "user" AS u,
     kudos AS k,
     has_variation AS hv,
     kudos_variation AS kv
WHERE u.username = k.sender_username
  AND k.kudos_id = hv.kudos_id
  AND hv.kudos_variation_id = kv.kudos_variation_id
  AND kv.kudos_variation_name = ?1
  AND u.username NOT IN (SELECT u2.sender_username
                         FROM kudos AS u2
                         GROUP BY u2.sender_username
                         HAVING COUNT(*) < 10)
GROUP BY u.username
HAVING COUNT(*) > 2
LIMIT 3;

-- Irmak's Query: Shows the person who gets the most kudos given kudos type
-- and the projects this person is currently working on.

WITH user_and_count
         AS (SELECT kudos.recipient_username AS username, COUNT(*) AS n_kudos
             FROM kudos
             WHERE kudos.kudos_id IN (SELECT H.kudos_id
                                      FROM has_variation AS H,
                                           kudos_variation AS K
                                      WHERE K.kudos_variation_name = ?1
                                        AND H.kudos_variation_id = K.kudos_variation_id)
             GROUP BY kudos.recipient_username
    )
SELECT u.username AS username, p.project_name AS project
FROM "user" AS u,
     project AS p,
     works_on AS w
WHERE u.user_id = w.user_id
  AND w.project_id = p.project_id
  AND u.username =
      (SELECT username FROM user_and_count WHERE n_kudos = (SELECT MAX(n_kudos) FROM user_and_count) LIMIT 1);

-- Kerem's Query: Shows users who work on the given project, are recieved all of the kudos types
-- and sent any of the kudos type.

WITH usernames AS
         (
             SELECT DISTINCT a.username
             FROM (SELECT u.username AS username
                   FROM "user" AS u
                   WHERE NOT EXISTS(SELECT DISTINCT K.kudos_variation_name
                                    FROM kudos_variation AS K
                                    WHERE K.kudos_variation_name NOT IN (SELECT DISTINCT K1.kudos_variation_name
                                                                         FROM kudos,
                                                                              kudos_variation AS K1,
                                                                              has_variation AS H
                                                                         WHERE kudos.recipient_username = u.username
                                                                           AND kudos.kudos_id = H.kudos_id
                                                                           AND H.kudos_variation_id = K1.kudos_variation_id))
                  ) AS a
                      INNER JOIN
                      (SELECT kudos.sender_username AS username FROM kudos) AS b
                      ON a.username = b.username
         )
SELECT u1.username, u1.first_name, u1.last_name
FROM "user" AS u1,
     project AS p,
     works_on AS w
WHERE u1.user_id = w.user_id
  AND w.project_id = p.project_id
  AND p.project_name = ?1
  AND u1.username IN (SELECT DISTINCT username FROM usernames)
LIMIT 3;
