import { forwardRef } from "react";
import type { HTMLAttributes, ReactNode } from "react";
import { clsx } from "clsx";
import { Button } from "../Button/Button";

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  title: string;
  pip?: number;
  children: ReactNode;
}

// Deliberately uses raw HTML containers (`<section>`, `<header>`, `<ul>`),
// arbitrary spacing values (`m-[3px]`, `gap-[7px]`), and inline style
// (`style={...}`) so the archaeology pipeline has something to find.
export const Card = forwardRef<HTMLDivElement, CardProps>(function Card(
  { title, pip, children, ...rest },
  ref,
) {
  return (
    <section
      ref={ref}
      className={clsx("flex flex-col gap-[7px] m-[3px] bg-surface-raised border-border-subtle", "rounded-md")}
      style={{ padding: "12px" }}
      {...rest}
    >
      <header className="flex flex-row gap-2">
        {title}
        <Button pip={pip}>Action</Button>
      </header>
      <Button pip={3}>Other</Button>
      <ul className="m-0 p-0">
        <li>{children}</li>
      </ul>
    </section>
  );
});
