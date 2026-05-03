---
name: tanstack-integration
description: How each TanStack abstraction (Query, DB, Form, Table, Virtual, Store, Pacer, Virtual) maps onto each atomic-design level — the prop shapes, controlled / uncontrolled patterns, ref forwarding, and aria wiring that make atoms drop into TanStack Form fields, molecules wrap a `field` cleanly, organism tables consume a TanStack Table instance, organism lists / grids consume TanStack DB collections (or Query results), and animation hooks into Motion / Reanimated. The integration rulebook that the audit workflows enforce. Load when designing or refactoring any interactive component, when reviewing an organism for "did it use the right TanStack primitive", when integrating a form / table / list, or when porting a web component to React Native (the TanStack abstractions are identical cross-platform).
when_to_use: Designing atom / molecule / organism API; refactoring a component off bespoke `useState([])` to TanStack DB; wiring a form with TanStack Form; wiring a table with TanStack Table; integrating Motion / Reanimated; cross-platform (web ↔ native) component design.
paths: "**/atoms/**, **/molecules/**, **/organisms/**, **/templates/**, **/pages/**, **/components/**"
---

# TanStack Integration

How TanStack primitives map onto **atomic-design** levels — the contract every component in this design system follows so the layers compose cleanly. This skill operationalizes the policy in `approved-libraries`: it tells you *how* atoms accept a Form field, *how* organism tables wrap TanStack Table, *how* lists feed from TanStack DB collections.

The rules are platform-agnostic — the same prop shapes work on web (with Tailwind + Motion) and React Native (with NativeWind + Reanimated), because TanStack abstractions don't care about the rendering target.

## Atoms — the "field-friendly atom" contract

Every interactive atom (Input, Textarea, Checkbox, Switch, Select, Slider, Combobox trigger, etc.) **must** expose this prop shape so it drops into a TanStack Form `field` without an adapter:

```tsx
type FieldFriendlyAtomProps<T> = {
  value: T;
  onChange: (next: T) => void;        // value-first, NOT (event) => void
  onBlur?: () => void;                // synced to field.handleBlur
  name?: string;                       // synced to field.name
  disabled?: boolean;
  required?: boolean;
  // a11y wiring TanStack Form's field.state.meta drives:
  'aria-invalid'?: boolean;
  'aria-describedby'?: string;
  // ref forwarding for focus / measure / scroll-into-view:
  ref?: React.Ref<HTMLInputElement | TextInput | …>;
};
```

### Why value-first, not event-first?

`onChange(e: ChangeEvent)` looks fine in raw HTML but breaks two things in our stack:
- **Native**: there is no `ChangeEvent`. RN passes the value directly. A web atom that emits an event can't be reused on native without a translation layer.
- **TanStack Form**: `field.handleChange(value)` takes the value, not the event. Atoms that emit events force every consumer to write `(e) => field.handleChange(e.target.value)` — boilerplate everywhere.

Emit the **value**. Consumers translate from event to value at the atom boundary if needed.

### Web example — Input atom

```tsx
import { forwardRef } from 'react';
import { cn } from '@/lib/cn';

type InputProps = {
  value: string;
  onChange: (v: string) => void;
  onBlur?: () => void;
  name?: string;
  disabled?: boolean;
  required?: boolean;
  'aria-invalid'?: boolean;
  'aria-describedby'?: string;
  className?: string;
} & Omit<React.InputHTMLAttributes<HTMLInputElement>, 'value' | 'onChange' | 'onBlur'>;

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ value, onChange, onBlur, className, ...rest }, ref) => (
    <input
      ref={ref}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      onBlur={onBlur}
      className={cn('h-9 rounded-md border bg-background px-3 …', className)}
      {...rest}
    />
  ),
);
```

### Native example — Input atom

```tsx
import { forwardRef } from 'react';
import { TextInput, type TextInput as TextInputRef } from 'react-native';

type InputProps = {
  value: string;
  onChange: (v: string) => void;
  onBlur?: () => void;
  name?: string;
  editable?: boolean;
  'aria-invalid'?: boolean;
};

export const Input = forwardRef<TextInputRef, InputProps>(
  ({ value, onChange, onBlur, ...rest }, ref) => (
    <TextInput
      ref={ref}
      value={value}
      onChangeText={onChange}                // RN already passes value-first
      onBlur={onBlur}
      className="h-10 rounded-md border bg-background px-3 …"  // NativeWind
      {...rest}
    />
  ),
);
```

Note the API is identical from the consumer's view. The platform difference is hidden inside the atom.

## Molecules — the "field wrapper" molecule

`FormField` and any molecule that ships a labelled control accepts a TanStack Form `field` as its primary prop. It does the wiring once so consumers never repeat it.

```tsx
import { type FieldApi } from '@tanstack/react-form';
import { Input } from '@/components/atoms/Input';
import { Label } from '@/components/atoms/Label';
import { HelperText } from '@/components/atoms/HelperText';
import { ErrorText } from '@/components/atoms/ErrorText';

type FormFieldProps<TData, TName extends keyof TData> = {
  field: FieldApi<TData, TName>;
  label: string;
  helper?: string;
  // optional: which atom to render — defaults to <Input>
  as?: React.ComponentType<{
    value: any;
    onChange: (v: any) => void;
    onBlur?: () => void;
    name?: string;
    'aria-invalid'?: boolean;
    'aria-describedby'?: string;
  }>;
};

export function FormField<TData, TName extends keyof TData>({
  field,
  label,
  helper,
  as: Control = Input,
}: FormFieldProps<TData, TName>) {
  const errorId = `${field.name}-error`;
  const helperId = `${field.name}-helper`;
  const isInvalid = !field.state.meta.isValid && field.state.meta.isTouched;

  return (
    <div className="flex flex-col gap-1">
      <Label htmlFor={field.name}>{label}</Label>
      <Control
        name={field.name}
        value={field.state.value}
        onChange={field.handleChange}
        onBlur={field.handleBlur}
        aria-invalid={isInvalid || undefined}
        aria-describedby={
          [helper && helperId, isInvalid && errorId].filter(Boolean).join(' ') || undefined
        }
      />
      {helper && <HelperText id={helperId}>{helper}</HelperText>}
      {isInvalid && (
        <ErrorText id={errorId} role="alert">
          {field.state.meta.errors.join(', ')}
        </ErrorText>
      )}
    </div>
  );
}
```

Consumers do this:

```tsx
<form.Field name="email">
  {(field) => <FormField field={field} label="Email" helper="We never spam." />}
</form.Field>
```

`FormField`'s job: hide the `aria-invalid` / `aria-describedby` / error-text wiring that every team gets wrong if they roll it themselves.

### Form-level molecules / organisms

Forms themselves use TanStack Form's `useForm` directly. The form-level component renders a `<form onSubmit>` that calls `form.handleSubmit()`. Schema validation hooks in via Standard Schema:

```tsx
import { useForm } from '@tanstack/react-form';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export function SignInForm({ onSignedIn }: { onSignedIn: () => void }) {
  const form = useForm({
    defaultValues: { email: '', password: '' },
    validators: { onChange: schema },
    onSubmit: async ({ value }) => {
      await api.signIn(value);
      onSignedIn();
    },
  });

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        form.handleSubmit();
      }}
    >
      <form.Field name="email">
        {(field) => <FormField field={field} label="Email" />}
      </form.Field>
      <form.Field name="password">
        {(field) => <FormField field={field} label="Password" />}
      </form.Field>
      <Button type="submit" disabled={!form.state.canSubmit}>Sign in</Button>
    </form>
  );
}
```

## Organisms — tables consume a TanStack Table instance

`DataTable` and any table-shaped organism accepts a `table` instance, not raw `data + columns`:

```tsx
import { type Table, flexRender } from '@tanstack/react-table';

export function DataTable<T>({ table }: { table: Table<T> }) {
  return (
    <table>
      <thead>
        {table.getHeaderGroups().map((hg) => (
          <tr key={hg.id}>
            {hg.headers.map((h) => (
              <th key={h.id} onClick={h.column.getToggleSortingHandler()}>
                {flexRender(h.column.columnDef.header, h.getContext())}
              </th>
            ))}
          </tr>
        ))}
      </thead>
      <tbody>
        {table.getRowModel().rows.map((row) => (
          <tr key={row.id}>
            {row.getVisibleCells().map((cell) => (
              <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

The page composes the table:

```tsx
const table = useReactTable({
  data: users,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  state: { sorting, columnFilters },
  onSortingChange: setSorting,
  onColumnFiltersChange: setColumnFilters,
});

<DataTable table={table} />
```

The organism owns rendering; the page owns the column model and feature opt-ins. **Never** pass `data` and `columns` separately to the organism — that breaks the headless contract.

For virtualization, the organism wraps `useVirtualizer` from TanStack Virtual:

```tsx
const rowVirtualizer = useVirtualizer({
  count: rows.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 36,
  overscan: 8,
});
```

## Organisms — lists / grids feed from TanStack DB collections

Any organism that renders a "list of things from the server" consumes a **TanStack DB collection**, not raw query data:

```tsx
import { useLiveQuery } from '@tanstack/react-db';
import { usersCollection } from '@/data/collections/users';

export function UserList({ filter }: { filter: string }) {
  const { data: users } = useLiveQuery((q) =>
    q.from({ user: usersCollection })
      .where(({ user }) => user.name.toLowerCase().includes(filter.toLowerCase()))
      .orderBy(({ user }) => user.name),
  );

  return (
    <ul>
      {users.map((u) => <UserListItem key={u.id} user={u} />)}
    </ul>
  );
}
```

Where `usersCollection` is defined once at the data layer and fed by Query:

```tsx
import { createCollection } from '@tanstack/react-db';
import { queryCollectionOptions } from '@tanstack/query-db-collection';
import { queryClient } from '@/lib/query-client';
import { z } from 'zod';

export const userSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});
export type User = z.infer<typeof userSchema>;

export const usersCollection = createCollection(
  queryCollectionOptions({
    id: 'users',
    queryKey: ['users'],
    queryFn: async () => api.users.list(),
    queryClient,
    schema: userSchema,
    getKey: (u) => u.id,
  }),
);
```

Why not just `useQuery(['users'])` and feed `data.map(...)`?

- **Cross-collection joins** — DB does them in the live query.
- **Reactivity to mutations** — DB recomputes only the changed slice (differential dataflow).
- **Optimistic updates** propagate to every subscriber automatically.
- **Persistence + offline** is one option flag, not a custom layer.

Read-only, single-shot data that won't be queried locally? Use `useQuery` directly. Anything reactive, queryable, or shared across multiple organisms? Use a DB collection.

## State (UI, non-server, non-form) — TanStack Store / Zustand

`useState` is fine within a component. **Cross-component UI state** (sidebar open, theme, modal stack, command-palette state) goes through TanStack Store (or Zustand as approved alternate):

```tsx
import { Store, useStore } from '@tanstack/store';

export const uiStore = new Store({
  sidebarOpen: false,
  commandPaletteOpen: false,
  theme: 'system' as 'light' | 'dark' | 'system',
});

export function SidebarToggle() {
  const open = useStore(uiStore, (s) => s.sidebarOpen);
  return (
    <Button
      onClick={() => uiStore.setState((s) => ({ ...s, sidebarOpen: !s.sidebarOpen }))}
    >
      {open ? 'Close' : 'Open'}
    </Button>
  );
}
```

**Don't** put server-derived state in a store; that's TanStack Query / DB's job. **Don't** put form state in a store; that's TanStack Form's job. Stores hold **UI state that has no other home**.

## Animation — Motion (web) / Reanimated (native)

Atoms / molecules animate via Motion (web) or Reanimated (native). The animation hooks live inside the atom, not the consumer:

### Web

```tsx
import { motion, useReducedMotion } from 'motion/react';

export function Toast({ open, children }: { open: boolean; children: React.ReactNode }) {
  const reduce = useReducedMotion();
  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={reduce ? false : { y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={reduce ? { opacity: 0 } : { y: 20, opacity: 0 }}
          transition={{ duration: 0.2 }}
          role="status"
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

### Native

```tsx
import Animated, { useAnimatedStyle, withSpring, useReducedMotion } from 'react-native-reanimated';

export function Toast({ open, children }: { open: boolean; children: React.ReactNode }) {
  const reduce = useReducedMotion();
  const style = useAnimatedStyle(() => ({
    opacity: withSpring(open ? 1 : 0, reduce ? { duration: 0 } : { damping: 14 }),
    transform: [{ translateY: withSpring(open ? 0 : 20, reduce ? { duration: 0 } : { damping: 14 }) }],
  }));
  return <Animated.View style={style}>{children}</Animated.View>;
}
```

**`prefers-reduced-motion` is mandatory** on every animated component. The audit workflows fail components that animate without honoring it.

## Debounce / throttle — TanStack Pacer

Search inputs, autosave, expensive recomputations — Pacer:

```tsx
import { useDebouncedCallback } from '@tanstack/react-pacer';

const onSearch = useDebouncedCallback(
  (q: string) => fetchResults(q),
  { wait: 300 },
);
```

**Don't** import lodash for debounce. Pacer is typed, hook-aware, and tree-shakable.

## Cross-platform component split

A component that targets web AND native splits at the file level, not at the prop level:

```
src/components/atoms/Input/
├── Input.tsx          # web
├── Input.native.tsx   # RN (auto-resolved by Metro)
├── Input.shared.ts    # types + behavior shared across platforms
├── Input.stories.tsx  # web Storybook
└── Input.mdx
```

The shared types file holds the `FieldFriendlyAtomProps<T>` shape. Both implementations satisfy it. Consumers import `'@/components/atoms/Input'` and the bundler picks the right file.

## What the audit checks

`/design-storybook-atomic:audit-libraries` (and indirectly `audit-atomic` / `audit-molecules` / `audit-organisms`) verify:

- ✅ Every interactive atom matches `FieldFriendlyAtomProps`.
- ✅ Every form-shaped molecule accepts a `field` prop.
- ✅ Every table-shaped organism accepts a TanStack Table `table` instance.
- ✅ Every list / grid organism that fetches data uses a TanStack DB collection or a TanStack Query result (not bespoke `useState([])`).
- ✅ No lodash debounce / throttle / once.
- ✅ No `Animated` (RN's legacy API) — only Reanimated.
- ✅ No event-first `onChange(e)` on atoms — only value-first `onChange(v)`.
- ✅ Every animated component honors `prefers-reduced-motion` or RN's `useReducedMotion`.
- ✅ Cross-component UI state lives in a store, not in scattered `useState` lifted as deep prop chains.

Each violation appears in the audit report with `path:line` and the canonical fix.

## Relationship to other skills in this plugin

- **`approved-libraries`** — declares which libraries are in use; this skill operationalizes them.
- **`atomic-design`** — defines the levels these patterns target.
- **`component-composition`** — composition patterns (slots / compound / `asChild`) work alongside these TanStack rules.
- **`storybook-authoring`** — stories must demonstrate the field / table / collection integration so the integration is verifiable in Storybook.
- **`audit-libraries`** — the workflow that runs the policy.

## Further reading

- TanStack Form docs — https://tanstack.com/form/latest
- TanStack DB docs — https://tanstack.com/db/latest
- TanStack Table docs — https://tanstack.com/table/latest
- TanStack Pacer docs — https://tanstack.com/pacer/latest
- Motion (web) — https://motion.dev/
- Reanimated 3 docs — https://docs.swmansion.com/react-native-reanimated/
