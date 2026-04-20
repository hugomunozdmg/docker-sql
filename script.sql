-- =========================================
-- 1️⃣ Insertar clientes
-- =========================================
INSERT INTO clients (dive_center_id, full_name, email)
SELECT
  CASE
    WHEN i <= 30 THEN 1
    WHEN i <= 38 THEN 2
    WHEN i <= 44 THEN 3
    ELSE 4
  END,
  'Client ' || i,
  'client' || i || '@example.com'
FROM generate_series(1, 50) i;


-- Insertar preferredDiveDate aleatorio entre enero y febrero 2026 para cada cliente
INSERT INTO form_answers (client_id, question_id, form_type_id, answer)
SELECT
  c.client_id,
  q.question_id,
  q.form_type_id,
  to_jsonb(
    date '2026-01-01' + (random() * 59)::int  -- 59 días entre 2026-01-01 y 2026-02-28
  )
FROM clients c
JOIN form_questions q 
  ON q.form_type_id = 2
  AND q.code = 'preferredDiveDate'
ON CONFLICT (client_id, question_id) DO UPDATE 
SET answer = EXCLUDED.answer;
