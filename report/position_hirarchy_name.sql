SELECT distinct aa.GLOBAL_NAME, cc.NAME
  FROM hr.per_all_people_f aa, hr.per_all_assignments_f bb, per_positions cc
 WHERE aa.person_id = bb.person_id AND cc.position_id = bb.position_id
 