-- ================================
-- Tablas base para dive center, usuarios y clientes
-- ================================

CREATE TABLE IF NOT EXISTS dive_centers (
    dive_center_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(500) NOT NULL
);

CREATE TABLE IF NOT EXISTS user_dive_centers (
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    dive_center_id INT NOT NULL REFERENCES dive_centers(dive_center_id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (user_id, dive_center_id)
);


CREATE TABLE IF NOT EXISTS clients (
    client_id SERIAL PRIMARY KEY,
    dive_center_id INT NOT NULL REFERENCES dive_centers(dive_center_id),
    full_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    CONSTRAINT clients_fullname_divecenter_unique
        UNIQUE (full_name, dive_center_id)
);

CREATE TABLE IF NOT EXISTS form_types (
    form_type_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================
-- Insertar un tipo de formulario por defecto
-- ================================

INSERT INTO form_types (name)
VALUES 
('Medical Diving Questionnaire'),
('Personal Data'),
('Safe agreement'),
('Rental contract'),
('Risk agreement');


CREATE TABLE IF NOT EXISTS client_forms (
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    form_type_id INT NOT NULL REFERENCES form_types(form_type_id),
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    PRIMARY KEY (client_id, form_type_id)
);

-- ================================
-- Tablas para cuestionario
-- ================================

CREATE TABLE IF NOT EXISTS form_questions (
    question_id SERIAL PRIMARY KEY,
    form_type_id INT NOT NULL REFERENCES form_types(form_type_id),
    code TEXT NOT NULL,
    text TEXT NOT NULL,
    parent_question_id INT REFERENCES form_questions(question_id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS form_answers (
    answer_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    question_id INT NOT NULL REFERENCES form_questions(question_id),
    form_type_id INT NOT NULL,
    answer jsonb NOT NULL,
    answered_at TIMESTAMP DEFAULT NOW(),
    UNIQUE (client_id, question_id)
);

CREATE TABLE IF NOT EXISTS completed_forms (
    form_id INT NOT NULL REFERENCES form_types(form_type_id),
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_google_tokens (
    user_id INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE IF NOT EXISTS activities (
    activity_id SERIAL PRIMARY KEY,
    dive_center_id INT NOT NULL REFERENCES dive_centers(dive_center_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    price NUMERIC(10,2),
    color CHAR(7)
);


-- Tabla de pagadores
CREATE TABLE IF NOT EXISTS payers (
    payer_id SERIAL PRIMARY KEY,
    dive_center_id INT NOT NULL REFERENCES dive_centers(dive_center_id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);


CREATE TABLE IF NOT EXISTS activities_calendar (
    activity_calendar_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    date TEXT NOT NULL,
    activity_id INT NOT NULL REFERENCES activities(activity_id),
    time TEXT NOT NULL,
    payment FLOAT NOT NULL,
    payer_id INT NOT NULL REFERENCES payers(payer_id)
);


-- Pagos realizados

CREATE TABLE done_payments (
    done_payment_id SERIAL PRIMARY KEY,
    activity_calendar_id INT NOT NULL REFERENCES activities_calendar(activity_calendar_id) ON DELETE CASCADE,
    payer_id INT NOT NULL REFERENCES payers(payer_id) ON DELETE CASCADE,
    quantity FLOAT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE public_form_tokens (
  token UUID PRIMARY KEY,
  dive_center_id INT NOT NULL REFERENCES dive_centers(dive_center_id) ON DELETE CASCADE,
  created_by_user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
  expires_at TIMESTAMP,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE stripe_account (
    user_id INT NOT NULL REFERENCES users(user_id),
    stripe_account_id VARCHAR(50) NOT NULL,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id)
);





-- ==================================
-- Formulario: Cuestionario medico
-- form_type_id = 1
-- ==================================

-- Preguntas principales
INSERT INTO form_questions (form_type_id, code, text)
VALUES
(1, 'question1', '1. I have had problems with my lungs, breathing, heart and/or blood affecting my normal physical or mental performance.'),
(1, 'question2', '2. I am over 45 years of age.'),
(1, 'question3', '3. I struggle to perform moderate exercise (for example, walk 1.6 kilometer/one mile in 14 minutes or swim 200 meters/yards without resting), OR I have been unable to participate in a normal physical activity due to fitness or health reasons within the past 12 months.'),
(1, 'question4', '4. I have had problems with my eyes, ears, or nasal passages/sinuses.'),
(1, 'question5', '5. I have had surgery within the last 12 months, OR I have ongoing problems related to past surgery.'),
(1, 'question6', '6. I have lost consciousness, had migraine headaches, seizures, stroke, significant head injury, or suffer from persistent neurologic injury or disease.'),
(1, 'question7', '7. I am currently undergoing treatment (or have required treatment within the last five years) for psychological problems, personality disorder, panic attacks, or an addiction to drugs or alcohol; or, I have been diagnosed with a learning or developmental disability.'),
(1, 'question8', '8. I have had back problems, hernia, ulcers, or diabetes.'),
(1, 'question9', '9. I have had stomach or intestine problems, including recent diarrhea.'),
(1, 'question10', '10. I am taking prescription medications (with the exception of birth control or anti-malarial drugs other than mefloquine (Lariam)).');

-- Subpreguntas de question1
INSERT INTO form_questions (form_type_id, code, text, parent_question_id)
VALUES
(1, 'question1_1', 'Chest surgery, heart surgery, heart valve surgery, an implantable medical device (eg, stent, pacemaker, neurostimulator), pneumothorax, and/or chronic lung disease.', 1),
(1, 'question1_2', 'Asthma, wheezing, severe allergies, hay fever or congested airways within the last 12 months that limits my physical activity/exercise.', 1),
(1, 'question1_3', 'A problem or illness involving my heart such as: angina, chest pain on exertion, heart failure, immersion pulmonary edema, heart attack or stroke, OR am taking medication for any heart condition.', 1),
(1, 'question1_4', 'Recurrent bronchitis and currently coughing within the past 12 months, OR have been diagnosed with emphysema.', 1),
(1, 'question1_5', 'A diagnosis of COVID-19.', 1);

-- Subpreguntas de question2
INSERT INTO form_questions (form_type_id, code, text, parent_question_id)
VALUES
(1, 'question2_1', 'I currently smoke or inhale nicotine by other means.', 2),
(1, 'question2_2', 'I have a high cholesterol level.', 2),
(1, 'question2_3', 'I have high blood pressure.', 2),
(1, 'question2_4', 'I have had a close blood relative die suddenly or of cardiac disease or stroke before the age of 50, OR have a family history of heart disease before age 50 (including abnormal heart rhythms, coronary artery disease or cardiomyopathy).', 2);

-- Subpreguntas de question4
INSERT INTO form_questions (form_type_id, code, text, parent_question_id)
VALUES
(1, 'question4_1', 'Sinus surgery within the last 6 months.', 4),
(1, 'question4_2', 'Ear disease or ear surgery, hearing loss, or problems with balance.', 4),
(1, 'question4_3', 'Recurrent sinusitis within the past 12 months.', 4),
(1, 'question4_4', 'Eye surgery within the past 3 months', 4);

-- Subpreguntas de question6
INSERT INTO form_questions (form_type_id, code, text, parent_question_id)
VALUES
(1, 'question6_1', 'Head injury with loss of consciousness within the past 5 years', 6),
(1, 'question6_2', 'Persistent neurologic injury or disease', 6),
(1, 'question6_3', 'Recurring migraine headaches within the past 12 months, or take medications to prevent them.', 6),
(1, 'question6_4', 'Blackouts or fainting (full/partial loss of consciousness) within the last 5 years', 6),
(1, 'question6_5', 'Epilepsy, seizures, or convulsions, OR take medications to prevent them.', 6);

-- Subpreguntas de question7
INSERT INTO form_questions (form_type_id, code, text, parent_question_id)
VALUES
(1, 'question7_1', 'Behavioral health, mental or psychological problems requiring medical/psychiatric treatment', 7),
(1, 'question7_2', 'Major depression, suicidal ideation, panic attacks, uncontrolled bipolar disorder requiring medication/psychiatric treatment.', 7),
(1, 'question7_3', 'Been diagnosed with a mental health condition or a learning/developmental disorder that requires ongoing care or special accommodation.', 7),
(1, 'question7_4', 'An addiction to drugs or alcohol requiring treatment within the last 5 years.', 7);

-- Subpreguntas de question8
INSERT INTO form_questions (form_type_id, code, text, parent_question_id)
VALUES
(1, 'question8_1', 'Recurrent back problems in the last 6 months that limit my everyday activity', 8),
(1, 'question8_2', 'Back or spinal surgery within the last 12 months', 8),
(1, 'question8_3', 'Diabetes, either drug or diet controlled, OR gestational diabetes within the last 12 months.', 8),
(1, 'question8_4', 'An uncorrected hernia that limits my physical abilities', 8),
(1, 'question8_5', 'Active or untreated ulcers, problem wounds, or ulcer surgery within the last 6 months', 8);

-- Subpreguntas de question9
INSERT INTO form_questions (form_type_id, code, text, parent_question_id)
VALUES
(1, 'question9_1', 'Ostomy surgery and do not have medical clearance to swim or engage in physical activity.', 9),
(1, 'question9_2', 'Dehydration requiring medical intervention within the last 7 days.', 9),
(1, 'question9_3', 'Active or untreated stomach or intestinal ulcers or ulcer surgery within the last 6 months.', 9),
(1, 'question9_4', 'Frequent heartburn, regurgitation, or gastroesophageal reflux disease (GERD).', 9),
(1, 'question9_5', 'Active or uncontrolled ulcerative colitis or Crohn’s disease.', 9),
(1, 'question9_6', 'Bariatric surgery within the last 12 months', 9);

-- ===============================
-- Formulario: Personal Data Form
-- form_type_id = 2
-- ===============================

-- Preguntas principales
INSERT INTO form_questions (form_type_id, code, text)
VALUES
(2, 'email', 'Email'),
(2, 'name', 'Name'),
(2, 'last_name', 'Last name'),
(2, 'birthday', 'Birthday'),
(2, 'street', 'Street'),
(2, 'postal', 'ZIP/postal code'),
(2, 'country', 'Country of residence'),
(2, 'city', 'City'),
(2, 'phone', 'Phone number'),
(2, 'gender', 'Gender'), -- ======================
(2, 'certificationLevel', 'Certification level'), -- =======================
(2, 'padi_number', 'PADI number (if certified)'),
(2, 'numberOfDives', 'Number of dives'),
(2, 'dateOfLastDive', 'Date of last dive'),
(2, 'needRefresher', 'Do you need a refresher?'),
(2, 'haveInsurance', 'Do you have a diving insurance?'), -- =======================
(2, 'needEquipment', 'Do you need to rent a diving Equipment?'), -- =======================
(2, 'wantPhotosVideos', 'Do you want underwater pictures and videos?'),
(2, 'preferredDiveDate', 'Preferred date of your dives'),
(2, 'stayDuration', 'How long are you staying on the island?'),
(2, 'departureDate', 'Departure Date'),
(2, 'promotionsEmail', 'Do you want us to email you with special promotions?'),
(2, 'consentSocialMedia', 'Do you give us consent to post you on social media?'),
(2, 'howDidYouKnow', 'How did you know about us?'); -- ===========================


-- haveInsurance (question_id = 59) → yes/no + subquestions
INSERT INTO form_questions (form_type_id, code, text, parent_question_id) VALUES
(2, 'insuranceNumber', 'Insurance Number', 59),
(2, 'insuranceCompany', 'Insurance Company', 59);

-- needEquipment (question_id = 60) → yes/no + subquestions
INSERT INTO form_questions (form_type_id, code, text, parent_question_id) VALUES
(2, 'bootsSize', 'Boots Size', 60),
(2, 'bcdSize', 'BCD Size', 60),
(2, 'wetsuitSize', 'Wetsuit Size', 60);



-- ===============================
-- Formulario: Rental contract
-- form_type_id = 4
-- ===============================

INSERT INTO form_questions (form_type_id, code, text) VALUES
(4, 'days', 'Days');






-- ELIMINAR TODAS LAS TABLAS
-- ============================
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;
-- ============================
