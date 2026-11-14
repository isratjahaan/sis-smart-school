import { z } from 'zod';

export const sduiComponentTypeSchema = z.enum([
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

export const sduiActionSchema = z.object({
  type: z.enum(['navigate', 'external_url', 'open_modal', 'call_phone', 'trigger_refresh']),
  target: z.string().min(1),
  params: z.record(z.unknown()).optional(),
});

export const sduiComponentConfigSchema = z.object({
  id: z.string().min(1),
  type: sduiComponentTypeSchema,
  visible: z.boolean().default(true),
  order: z.number().int().min(0),
  title: z.string().optional(),
  subtitle: z.string().optional(),
  props: z.record(z.unknown()).optional().default({}),
  action: sduiActionSchema.optional(),
  allowedRoles: z.array(z.string()).optional(),
});

export const sduiScreenLayoutSchema = z.object({
  screenId: z.string().min(1),
  version: z.number().int().min(1),
  title: z.string().optional(),
  components: z.array(sduiComponentConfigSchema),
  updatedAt: z.string(),
});

export const sduiNavigationItemSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  icon: z.string().min(1),
  route: z.string().min(1),
  badgeCount: z.number().int().optional(),
  visible: z.boolean().default(true),
  order: z.number().int().min(0),
  requiredRole: z.array(z.string()).optional(),
  featureFlag: z.string().optional(),
});

export const sduiNavigationConfigSchema = z.object({
  school_id: z.string().uuid().optional().nullable(),
  role: z.string().min(1),
  items: z.array(sduiNavigationItemSchema),
  version: z.number().int().min(1),
  updated_at: z.string(),
});

export type SDUIScreenLayoutInput = z.infer<typeof sduiScreenLayoutSchema>;
export type SDUINavigationConfigInput = z.infer<typeof sduiNavigationConfigSchema>;
