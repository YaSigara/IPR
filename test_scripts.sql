DELETE FROM events;
DELETE FROM contacts;
DELETE FROM friends;

WITH friend_pairs(ffn, fln, sfn, sln) AS (
	VALUES ('Ralph', 'Schumacher', 'Michael', 'Schumacher'),
	('Ralph', 'Schumacher', 'Michael', 'Schumacher'),
	('Ralph', 'Schumacher', 'Fernando', 'Alonso'),
	('Michael', 'Schumacher', 'Ralph', 'Schumacher'),
	('Fernando', 'Alonso', 'Ralph', 'Schumacher'),
	('Michael', 'Andretti', 'Fernando', 'Alonso'),
	('Fernando', 'Alonso', 'Michael', 'Andretti'),
	('Fernando', 'Alonso', 'Carlos', 'Sainz'),
	('Fernando', 'Alonso', 'Jarno', 'Trulli'),
	('Carlos', 'Sainz', 'Fernando', 'Alonso'),
	('Sergei', 'Sirotkin', 'Vitaliy', 'Petrov'),
	('Vitaliy', 'Petrov', 'Sergei', 'Sirotkin'),
	('Jarno', 'Trulli', 'Vitaliy', 'Petrov'),
	('Vitaliy', 'Petrov', 'Jarno', 'Trulli')
)
Insert into friends(first_friend_id, second_friend_id)
SELECT u1.id, u2.id
FROM friend_pairs fp
JOIN users u1 on u1.first_name = fp.ffn and u1.last_name = fp.fln
JOIN users u2 on u2.first_name = fp.sfn and u2.last_name = fp.sln;

DELETE FROM contacts c
USING users u 
WHERE u.first_name = 'Fernando' 
and u.last_name = 'Alonso'
and c.friend_nickname = 'Jarno Trulli';

UPDATE contacts SET status = 'blocked'
WHERE owner = 2 and friend_nickname = 'Fernando Alonso';

UPDATE contacts SET status = 'blocked'
WHERE owner = 3 
and friend_nickname = 'Michael Andretti';

UPDATE contacts c SET status = 'active'
WHERE owner = 2 
and friend_nickname = 'Fernando Alonso';

INSERT INTO events(contact_id, owner_id, event_type) 
VALUES (6, 5, 'call');

INSERT INTO events(contact_id, owner_id, event_type) 
VALUES (3, 3, 'call');

SELECT * FROM events;


