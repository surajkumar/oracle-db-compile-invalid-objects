SET serveroutput ON SIZE 1000000;
DECLARE
  v_start DATE := SYSDATE;
  v_finish DATE;
  v_schema VARCHAR2(32);
  TYPE invalid_objects_r IS RECORD (object_owner VARCHAR2(240)
                                   ,object_name VARCHAR2(240)
                                   ,object_type VARCHAR2(240));
  TYPE invalid_objects_t IS TABLE OF invalid_objects_r;
  invalid_objects invalid_objects_t;
  pre_invalid_objects invalid_objects_t;
  CURSOR invalid_objects_c
  IS
    SELECT owner
         , object_name
         , object_type
      FROM all_objects
     WHERE upper(status) = upper('INVALID');
BEGIN
  BEGIN
    sys.utl_recomp.recomp_parallel(8);
  EXCEPTION
    WHEN OTHERS
      THEN dbms_output.put_line('Error with "sys.recomp_parallel": ' || SQLCODE ||':'|| SQLERRM);
  END;
  FOR x IN 1..2
  LOOP
    OPEN invalid_objects_c;
    FETCH invalid_objects_c BULK COLLECT INTO invalid_objects;
    CLOSE invalid_objects_c;
    FOR l_index IN invalid_objects.FIRST .. invalid_objects.LAST
    LOOP
      BEGIN
        IF invalid_objects(l_index).object_type = 'SYNONYM' THEN
          EXECUTE IMMEDIATE 'SELECT * FROM '
                             || invalid_objects(l_index).object_owner
                             || '.'
                             || invalid_objects(l_index).object_name
                             || ' WHERE 1=0';
        ELSIF invalid_objects(l_index).object_type = 'PACKAGE BODY' THEN
          EXECUTE IMMEDIATE 'ALTER PACKAGE '
                             || invalid_objects(l_index).object_owner
                             || '.'
                             || invalid_objects(l_index).object_name
                             || ' COMPILE BODY';
        ELSE
          EXECUTE IMMEDIATE 'ALTER '
                             || invalid_objects(l_index).object_type
                             || ' '
                             || invalid_objects(l_index).object_owner
                             || '.'
                             || invalid_objects(l_index).object_name
                             || ' COMPILE';
        END IF;
      EXCEPTION
        WHEN OTHERS
          THEN dbms_output.put_line('Error re-compiling '
                                    || invalid_objects(l_index).object_type
                                    || ' "'
                                    || invalid_objects(l_index).object_owner
                                    || '.'
                                    || invalid_objects(l_index).object_name
                                    || '":' || SQLCODE
                                    ||':'
                                    ||SQLERRM);
      END;
    END LOOP;
  END LOOP;
  v_finish := SYSDATE;
  dbms_output.put_line('');
  dbms_output.put_line('--------------------------------------------------------------');
  dbms_output.put_line('Invalid objects AFTER recompiling:');
  dbms_output.put_line('--------------------------------------------------------------');
  FOR l_index IN invalid_objects.FIRST .. invalid_objects.LAST
  LOOP
    dbms_output.put_line('[' || invalid_objects(l_index).object_type || '] '
                         || invalid_objects(l_index).object_owner
                         || '.'
                         || invalid_objects(l_index).object_name);
  END LOOP;
  dbms_output.put_line('--------------------------------------------------------------');
  dbms_output.put_line('Finished in ' || ((v_finish - v_start) * 60 * 60 * 24) || ' seconds');
EXCEPTION
  WHEN OTHERS
    THEN dbms_output.put_line('Outer Error: ' || SQLCODE ||':'|| SQLERRM);
END;
/
SHOW ERRORS