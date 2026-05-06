"use client";

import { forwardRef } from "react";
import type { ButtonHTMLAttributes, ReactNode } from "react";
import { clsx } from "clsx";

export interface ButtonProps extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, "type"> {
  /** Visual variant. Use `primary` for the page's main CTA. */
  variant?: "primary" | "secondary" | "ghost";
  /** Render size. */
  size?: "sm" | "md" | "lg";
  /** Disabled state — also sets `aria-disabled`. */
  disabled?: boolean;
  /** Required label. Children may be a node or a string. */
  children: ReactNode;
}

const SIZE_CX: Record<NonNullable<ButtonProps["size"]>, string> = {
  sm: "h-8 px-3 text-body-sm",
  md: "h-10 px-4 text-body",
  lg: "h-12 px-5 text-body-lg",
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  { variant = "primary", size = "md", disabled = false, className, children, ...rest },
  ref,
) {
  return (
    <button
      ref={ref}
      disabled={disabled}
      aria-disabled={disabled || undefined}
      className={clsx(
        "inline-flex items-center justify-center rounded-sm font-ui",
        "bg-accent text-text-inverse",
        SIZE_CX[size],
        className,
      )}
      style={{ color: "var(--color-text-inverse)" }}
      {...rest}
    >
      {children}
    </button>
  );
});
