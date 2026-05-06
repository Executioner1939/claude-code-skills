import type { Meta, StoryObj } from "@storybook/react-vite";
import { Button } from "./Button";

// Fixture data — the `title:` here is REAL CONTENT, not a meta field.
// A naive regex rename would corrupt this. The structural parser must not.
const FIXTURE_LINKS = [
  { title: "Casual range session", href: "/book/casual" },
  { title: "Email verified", href: "/account" },
];

const meta = {
  title: "Atoms/Actions/Button",
  component: Button,
  tags: ["autodocs"],
  args: {
    variant: "primary",
    size: "md",
    children: "Click me",
  },
  argTypes: {
    variant: { control: "select", options: ["primary", "secondary", "ghost"] },
    size: { control: { type: "radio" }, options: ["sm", "md", "lg"] },
    children: { table: { disable: true } },
  },
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Primary: Story = {
  name: "Variants/Primary",
  args: { variant: "primary" },
};

export const Secondary: Story = {
  name: "Variants/Secondary",
  args: { variant: "secondary" },
};

export const Sizes: Story = {
  name: "Showcase/All sizes",
  render: () => (
    <>
      {(["sm", "md", "lg"] as const).map((size) => (
        <Button key={size} size={size}>
          {size}
        </Button>
      ))}
    </>
  ),
};

export const Disabled: Story = {
  name: "States/Disabled",
  args: { disabled: true, children: "Disabled" },
  play: async () => {
    /* interaction test placeholder */
  },
};

// Fixture references — no rename should ever touch these:
export const __FIXTURES__ = FIXTURE_LINKS;
