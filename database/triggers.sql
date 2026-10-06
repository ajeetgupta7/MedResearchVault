CREATE OR REPLACE FUNCTION trg_audit_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO audit_logs(table_name, record_id, action, details)
    VALUES (TG_TABLE_NAME, OLD::TEXT, TG_OP, to_jsonb(OLD));
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_logs(table_name, record_id, action, details)
    VALUES (TG_TABLE_NAME, NEW::TEXT, TG_OP, jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW)));
    RETURN NEW;
  ELSE
    INSERT INTO audit_logs(table_name, record_id, action, details)
    VALUES (TG_TABLE_NAME, NEW::TEXT, TG_OP, to_jsonb(NEW));
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_experiment_status_transition()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status NOT IN ('running','queued') THEN
    RAISE EXCEPTION 'Invalid status transition to completed from %', OLD.status;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_prevent_destroyed_sample_usage()
RETURNS TRIGGER AS $$
DECLARE
  v_status VARCHAR;
BEGIN
  SELECT status INTO v_status FROM samples WHERE sample_id = NEW.sample_id;
  IF v_status = 'destroyed' THEN
    RAISE EXCEPTION 'Destroyed sample cannot be used in experiment';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_studies ON studies;
CREATE TRIGGER trg_audit_studies
AFTER INSERT OR UPDATE OR DELETE ON studies
FOR EACH ROW EXECUTE FUNCTION trg_audit_changes();

DROP TRIGGER IF EXISTS trg_audit_participants ON participants;
CREATE TRIGGER trg_audit_participants
AFTER INSERT OR UPDATE OR DELETE ON participants
FOR EACH ROW EXECUTE FUNCTION trg_audit_changes();

DROP TRIGGER IF EXISTS trg_audit_experiments ON experiments;
CREATE TRIGGER trg_audit_experiments
AFTER INSERT OR UPDATE OR DELETE ON experiments
FOR EACH ROW EXECUTE FUNCTION trg_audit_changes();

DROP TRIGGER IF EXISTS trg_experiment_status_transition ON experiments;
CREATE TRIGGER trg_experiment_status_transition
BEFORE UPDATE OF status ON experiments
FOR EACH ROW EXECUTE FUNCTION trg_experiment_status_transition();

DROP TRIGGER IF EXISTS trg_prevent_destroyed_sample_usage ON experiments;
CREATE TRIGGER trg_prevent_destroyed_sample_usage
BEFORE INSERT OR UPDATE OF sample_id ON experiments
FOR EACH ROW EXECUTE FUNCTION trg_prevent_destroyed_sample_usage();
