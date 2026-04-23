# frozen_string_literal: true

module Everyday
  class TailwindToCssCalculator
    # Tailwind utility -> CSS value tables. Separated from the converter so
    # the mappings can be audited, extended, or partially overridden without
    # reading through the pattern-matching logic.
    module Mappings
      # Spacing scale for padding/margin/width/height/etc.
      SPACING_SCALE = {
        "0" => "0px", "px" => "1px", "0.5" => "0.125rem", "1" => "0.25rem",
        "1.5" => "0.375rem", "2" => "0.5rem", "2.5" => "0.625rem", "3" => "0.75rem",
        "3.5" => "0.875rem", "4" => "1rem", "5" => "1.25rem", "6" => "1.5rem",
        "7" => "1.75rem", "8" => "2rem", "9" => "2.25rem", "10" => "2.5rem",
        "11" => "2.75rem", "12" => "3rem", "14" => "3.5rem", "16" => "4rem",
        "20" => "5rem", "24" => "6rem", "28" => "7rem", "32" => "8rem",
        "36" => "9rem", "40" => "10rem", "44" => "11rem", "48" => "12rem",
        "52" => "13rem", "56" => "14rem", "60" => "15rem", "64" => "16rem",
        "72" => "18rem", "80" => "20rem", "96" => "24rem",
        "auto" => "auto", "full" => "100%", "screen" => "100vw"
      }.freeze

      # [font-size, line-height] pairs by size key.
      FONT_SIZE_SCALE = {
        "xs" => [ "0.75rem", "1rem" ], "sm" => [ "0.875rem", "1.25rem" ],
        "base" => [ "1rem", "1.5rem" ], "lg" => [ "1.125rem", "1.75rem" ],
        "xl" => [ "1.25rem", "1.75rem" ], "2xl" => [ "1.5rem", "2rem" ],
        "3xl" => [ "1.875rem", "2.25rem" ], "4xl" => [ "2.25rem", "2.5rem" ],
        "5xl" => [ "3rem", "1" ], "6xl" => [ "3.75rem", "1" ],
        "7xl" => [ "4.5rem", "1" ], "8xl" => [ "6rem", "1" ], "9xl" => [ "8rem", "1" ]
      }.freeze

      FONT_WEIGHT_SCALE = {
        "thin" => "100", "extralight" => "200", "light" => "300",
        "normal" => "400", "medium" => "500", "semibold" => "600",
        "bold" => "700", "extrabold" => "800", "black" => "900"
      }.freeze

      BORDER_RADIUS_SCALE = {
        "none" => "0px", "sm" => "0.125rem", "DEFAULT" => "0.25rem",
        "md" => "0.375rem", "lg" => "0.5rem", "xl" => "0.75rem",
        "2xl" => "1rem", "3xl" => "1.5rem", "full" => "9999px"
      }.freeze

      MAX_WIDTH_SCALE = {
        "none" => "none", "xs" => "20rem", "sm" => "24rem", "md" => "28rem",
        "lg" => "32rem", "xl" => "36rem", "2xl" => "42rem", "3xl" => "48rem",
        "4xl" => "56rem", "5xl" => "64rem", "6xl" => "72rem", "7xl" => "80rem",
        "full" => "100%", "screen" => "100vw"
      }.freeze

      STATIC_MAPPINGS = {
        # Display
        "block" => "display: block;",
        "inline-block" => "display: inline-block;",
        "inline" => "display: inline;",
        "flex" => "display: flex;",
        "inline-flex" => "display: inline-flex;",
        "grid" => "display: grid;",
        "inline-grid" => "display: inline-grid;",
        "hidden" => "display: none;",
        "table" => "display: table;",
        "table-row" => "display: table-row;",
        "table-cell" => "display: table-cell;",
        # Position
        "static" => "position: static;",
        "fixed" => "position: fixed;",
        "absolute" => "position: absolute;",
        "relative" => "position: relative;",
        "sticky" => "position: sticky;",
        # Flex
        "flex-row" => "flex-direction: row;",
        "flex-row-reverse" => "flex-direction: row-reverse;",
        "flex-col" => "flex-direction: column;",
        "flex-col-reverse" => "flex-direction: column-reverse;",
        "flex-wrap" => "flex-wrap: wrap;",
        "flex-wrap-reverse" => "flex-wrap: wrap-reverse;",
        "flex-nowrap" => "flex-wrap: nowrap;",
        "flex-1" => "flex: 1 1 0%;",
        "flex-auto" => "flex: 1 1 auto;",
        "flex-initial" => "flex: 0 1 auto;",
        "flex-none" => "flex: none;",
        "flex-grow" => "flex-grow: 1;",
        "flex-grow-0" => "flex-grow: 0;",
        "flex-shrink" => "flex-shrink: 1;",
        "flex-shrink-0" => "flex-shrink: 0;",
        # Justify & Align
        "justify-start" => "justify-content: flex-start;",
        "justify-end" => "justify-content: flex-end;",
        "justify-center" => "justify-content: center;",
        "justify-between" => "justify-content: space-between;",
        "justify-around" => "justify-content: space-around;",
        "justify-evenly" => "justify-content: space-evenly;",
        "items-start" => "align-items: flex-start;",
        "items-end" => "align-items: flex-end;",
        "items-center" => "align-items: center;",
        "items-baseline" => "align-items: baseline;",
        "items-stretch" => "align-items: stretch;",
        "self-auto" => "align-self: auto;",
        "self-start" => "align-self: flex-start;",
        "self-end" => "align-self: flex-end;",
        "self-center" => "align-self: center;",
        "self-stretch" => "align-self: stretch;",
        # Text
        "text-left" => "text-align: left;",
        "text-center" => "text-align: center;",
        "text-right" => "text-align: right;",
        "text-justify" => "text-align: justify;",
        "uppercase" => "text-transform: uppercase;",
        "lowercase" => "text-transform: lowercase;",
        "capitalize" => "text-transform: capitalize;",
        "normal-case" => "text-transform: none;",
        "italic" => "font-style: italic;",
        "not-italic" => "font-style: normal;",
        "underline" => "text-decoration-line: underline;",
        "overline" => "text-decoration-line: overline;",
        "line-through" => "text-decoration-line: line-through;",
        "no-underline" => "text-decoration-line: none;",
        "truncate" => "overflow: hidden;\ntext-overflow: ellipsis;\nwhite-space: nowrap;",
        # Overflow
        "overflow-auto" => "overflow: auto;",
        "overflow-hidden" => "overflow: hidden;",
        "overflow-visible" => "overflow: visible;",
        "overflow-scroll" => "overflow: scroll;",
        "overflow-x-auto" => "overflow-x: auto;",
        "overflow-y-auto" => "overflow-y: auto;",
        # Cursor
        "cursor-pointer" => "cursor: pointer;",
        "cursor-default" => "cursor: default;",
        "cursor-not-allowed" => "cursor: not-allowed;",
        "cursor-wait" => "cursor: wait;",
        # Other
        "sr-only" => "position: absolute;\nwidth: 1px;\nheight: 1px;\npadding: 0;\nmargin: -1px;\noverflow: hidden;\nclip: rect(0, 0, 0, 0);\nwhite-space: nowrap;\nborder-width: 0;",
        "not-sr-only" => "position: static;\nwidth: auto;\nheight: auto;\npadding: 0;\nmargin: 0;\noverflow: visible;\nclip: auto;\nwhite-space: normal;",
        "resize-none" => "resize: none;",
        "resize" => "resize: both;",
        "resize-x" => "resize: horizontal;",
        "resize-y" => "resize: vertical;",
        "select-none" => "user-select: none;",
        "select-text" => "user-select: text;",
        "select-all" => "user-select: all;",
        "select-auto" => "user-select: auto;",
        "pointer-events-none" => "pointer-events: none;",
        "pointer-events-auto" => "pointer-events: auto;",
        "appearance-none" => "appearance: none;",
        "outline-none" => "outline: 2px solid transparent;\noutline-offset: 2px;",
        "transition" => "transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter;\ntransition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);\ntransition-duration: 150ms;",
        "transition-none" => "transition-property: none;",
        "transition-all" => "transition-property: all;\ntransition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);\ntransition-duration: 150ms;",
        "transition-colors" => "transition-property: color, background-color, border-color, text-decoration-color, fill, stroke;\ntransition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);\ntransition-duration: 150ms;",
        "shadow-sm" => "box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);",
        "shadow" => "box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);",
        "shadow-md" => "box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);",
        "shadow-lg" => "box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);",
        "shadow-xl" => "box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);",
        "shadow-2xl" => "box-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.25);",
        "shadow-inner" => "box-shadow: inset 0 2px 4px 0 rgb(0 0 0 / 0.05);",
        "shadow-none" => "box-shadow: 0 0 #0000;"
      }.freeze
    end
  end
end
