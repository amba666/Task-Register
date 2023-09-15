WITH VMMC_CTE AS (
    SELECT
        ec_family_member.first_name,
        ec_family_member.middle_name,
        ec_family_member.last_name,
        ec_vmmc_enrollment.reffered_from,
        ec_vmmc_services.tested_hiv,
        ec_vmmc_services.hiv_result,
        ec_vmmc_procedure.mc_procedure_date,
        ec_vmmc_procedure.male_circumcision_method,
        ec_vmmc_follow_up_visit.visit_number,
        ec_vmmc_follow_up_visit.followup_visit_date AS visit_date,
        ec_vmmc_follow_up_visit.post_op_adverse_event_occur AS post_op_adverse,
        ec_vmmc_notifiable_ae.did_client_experience_nae AS NAE,
        ec_family_member.dob
    FROM
        ec_vmmc_enrollment
            INNER JOIN
        ec_family_member ON ec_family_member.base_entity_id = ec_vmmc_enrollment.base_entity_id
            INNER JOIN
        ec_vmmc_services ON ec_vmmc_services.entity_id = ec_vmmc_enrollment.base_entity_id
            INNER JOIN
        ec_vmmc_procedure ON ec_vmmc_procedure.entity_id = ec_vmmc_enrollment.base_entity_id
            INNER JOIN
        ec_vmmc_follow_up_visit ON ec_vmmc_follow_up_visit.entity_id = ec_vmmc_enrollment.base_entity_id
            LEFT JOIN
        ec_vmmc_notifiable_ae ON ec_vmmc_notifiable_ae.entity_id = ec_vmmc_enrollment.base_entity_id
    WHERE
            ec_vmmc_follow_up_visit.follow_up_visit_type = 'routine'
)
SELECT
        first_name || ' ' || middle_name || ' ' || last_name AS names,
    (strftime('%Y', 'now') - strftime('%Y', dob)) - (strftime('%m-%d', 'now') < strftime('%m-%d', dob)) AS age,
    reffered_from,
    tested_hiv,
    hiv_result,
    mc_procedure_date,
    male_circumcision_method,
    MAX(CASE WHEN visit_number = 0 THEN visit_date END) AS first_visit,
    MAX(CASE WHEN visit_number = 1 THEN visit_date END) AS sec_visit,
    MAX(post_op_adverse) AS post_op_adverse,
    MAX(NAE) AS NAE
FROM VMMC_CTE
GROUP BY
    names,
    age,
    reffered_from,
    tested_hiv,
    hiv_result,
    mc_procedure_date,
    male_circumcision_method;
