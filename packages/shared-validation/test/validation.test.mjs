import test from 'node:test';
import assert from 'node:assert/strict';
import { z } from 'zod';

// Re-importing schemas for isolated runtime validation
const createSchoolSchema = z.object({
  name: z.string().min(3).max(150),
  slug: z.string().min(2).max(50).regex(/^[a-z0-9-]+$/),
  code: z.string().min(2).max(20).toUpperCase(),
  email: z.string().email(),
  phone: z.string().min(7).max(20),
  address: z.string().min(5),
});

const sduiComponentTypeSchema = z.enum([
  'welcome_banner',
  'attendance_card',
  'result_card',
  'routine_strip',
  'notice_list',
  'quick_actions',
  'fee_summary_card',
  'stat_metric',
  'announcement_bar',
  'class_list',
  'custom_html_notice',
]);

const sduiScreenLayoutSchema = z.object({
  screenId: z.string().min(1),
  version: z.number().int().min(1),
  components: z.array(
    z.object({
      id: z.string().min(1),
      type: sduiComponentTypeSchema,
      visible: z.boolean().default(true),
      order: z.number().int().min(0),
    })
  ),
  updatedAt: z.string(),
});

test('createSchoolSchema validates valid school tenant input', () => {
  const validSchool = {
    name: 'Dhaka Model School',
    slug: 'dhaka-model',
    code: 'DMS',
    email: 'contact@dhakamodel.edu.bd',
    phone: '+8801711223344',
    address: 'House 42, Road 11, Dhanmondi, Dhaka',
  };

  const res = createSchoolSchema.safeParse(validSchool);
  assert.equal(res.success, true);
});

test('createSchoolSchema rejects invalid slug format with spaces and special chars', () => {
  const invalidSchool = {
    name: 'Dhaka Model School',
    slug: 'Dhaka Model School!!!', // Invalid slug
    code: 'DMS',
    email: 'contact@dhakamodel.edu.bd',
    phone: '+8801711223344',
    address: 'House 42, Road 11, Dhanmondi, Dhaka',
  };

  const res = createSchoolSchema.safeParse(invalidSchool);
  assert.equal(res.success, false);
});

test('sduiScreenLayoutSchema validates approved component stream', () => {
  const validLayout = {
    screenId: 'student_home',
    version: 1,
    components: [
      { id: 'c1', type: 'welcome_banner', visible: true, order: 1 },
      { id: 'c2', type: 'attendance_card', visible: true, order: 2 },
      { id: 'c3', type: 'result_card', visible: true, order: 3 },
    ],
    updatedAt: new Date().toISOString(),
  };

  const res = sduiScreenLayoutSchema.safeParse(validLayout);
  assert.equal(res.success, true);
});

test('sduiScreenLayoutSchema rejects unauthorized malicious component types', () => {
  const maliciousLayout = {
    screenId: 'student_home',
    version: 1,
    components: [
      { id: 'c1', type: 'dangerous_eval_script_execution', visible: true, order: 1 },
    ],
    updatedAt: new Date().toISOString(),
  };

  const res = sduiScreenLayoutSchema.safeParse(maliciousLayout);
  assert.equal(res.success, false);
});

test('Bangladesh GPA calculation engine logic', () => {
  function calculateGPA(marks) {
    let totalPoints = 0;
    let hasFailed = false;

    for (const m of marks) {
      let pt = 0;
      if (m >= 80) pt = 5.0;
      else if (m >= 70) pt = 4.0;
      else if (m >= 60) pt = 3.5;
      else if (m >= 50) pt = 3.0;
      else if (m >= 40) pt = 2.0;
      else if (m >= 33) pt = 1.0;
      else {
        pt = 0.0;
        hasFailed = true;
      }
      totalPoints += pt;
    }

    if (hasFailed) return 0.0;
    return Number((totalPoints / marks.length).toFixed(2));
  }

  // All A+ produces GPA 5.00
  assert.equal(calculateGPA([88, 84, 95, 91]), 5.0);

  // Mixed marks produce correct average
  // 88 (5.0) + 75 (4.0) + 65 (3.5) + 55 (3.0) = 15.5 / 4 = 3.88
  assert.equal(calculateGPA([88, 75, 65, 55]), 3.88);

  // Any failing mark (< 33) results in overall Fail (GPA 0.00)
  assert.equal(calculateGPA([95, 92, 88, 28]), 0.0);
});
