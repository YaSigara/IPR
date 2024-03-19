CREATE OR REPLACE FUNCTION insert_contact()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO contacts(owner, friend, friend_nickname, contact_phone)
    SELECT NEW.first_friend_id, NEW.second_friend_id,
        u.first_name || ' ' || u.last_name,
        c.code || '(' || mc.code || ')' || u.phone
    FROM users u
    JOIN countries c ON u.country = c.name
	JOIN mobile_companies mc ON mc.name = u.mobile_company
    WHERE u.id = NEW.second_friend_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER insert_contact_trigger
AFTER INSERT ON friends
FOR EACH ROW
EXECUTE FUNCTION insert_contact();
 -----------------------------------------------------------
CREATE OR REPLACE FUNCTION insert_event()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO events(contact_id, owner_id, event_type, comment)
    VALUES (NEW.id, NEW.owner, 'add', 'user with id = ' || NEW.owner || ' added ' || NEW.friend_nickname || 'as contact with phone ' || NEW.contact_phone);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER insert_event_trigger
AFTER INSERT ON contacts
FOR EACH ROW
EXECUTE FUNCTION insert_event();
----------------------------------------------------
CREATE OR REPLACE FUNCTION process_event()
RETURNS TRIGGER AS $$
BEGIN
IF TG_OP = 'DELETE' THEN
	INSERT INTO events(contact_id, owner_id, event_type, comment)
    VALUES (OLD.id, OLD.owner, 'delete', 'user with id = ' || OLD.owner || ' deleted ' || OLD.friend_nickname || 'from contacts');
ELSIF TG_OP = 'UPDATE' THEN 
CASE
WHEN NEW.status = 'blocked' AND OLD.status = 'active' THEN 
	INSERT INTO events(contact_id, owner_id, event_type, comment)
    VALUES (OLD.id, OLD.owner, 'block', 'user with id = ' || OLD.owner || ' blocked ' || OLD.friend_nickname);
WHEN NEW.status = 'active' AND OLD.status = 'blocked' THEN 
	INSERT INTO events(contact_id, owner_id, event_type, comment)
    VALUES (OLD.id, OLD.owner, 'unblock', 'user with id = ' || OLD.owner || ' unblocked ' || OLD.friend_nickname);
END CASE;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER process_event_trigger
AFTER UPDATE OR DELETE ON contacts
FOR EACH ROW
EXECUTE FUNCTION process_event();
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION process_call_event()
RETURNS TRIGGER AS $$
BEGIN
IF NEW.event_type = 'call' AND EXISTS (
  SELECT 1
  FROM contacts cf
  JOIN contacts co ON co.id = NEW.contact_id
  WHERE NEW.owner_id = cf.friend AND cf.owner = co.friend AND cf.status = 'blocked'
) 
	THEN 
	NEW.success := false;
	NEW.comment := 'user with id = ' || NEW.owner_id || ' ried to call ' || 
	(SELECT c.friend_nickname 
	 FROM contacts c 
	 WHERE c.id = NEW.contact_id) || ' but was blocked';
ELSIF NEW.event_type = 'call' 
THEN NEW.comment := 'user with id = ' || NEW.owner_id || ' called ' || (SELECT c.friend_nickname FROM contacts c WHERE c.id = NEW.contact_id);
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER call_event_trigger
BEFORE INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION process_call_event();