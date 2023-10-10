// References: https://www.cloudflarestatus.com/
// Written in: Thursday, September 1, 2022
// Executed every six months, Cloudflare will add new location Edge servers from time to time.
// We need to stay in sync.

// Page -> Crystal Playground
// \ \ \ \ |\"|\"\,|\[|\]|(\,$) =>
// \ \-(\ |\ ) => - 

// Crystal Playground -> PlainText
// \]|\[|\"|(\,$)|(^\ ) =>

// PlainText -> Enum IATA
// .*\((\w{3})\)( = \d+_i32) => \1\2

// PlainText -> Enum Edge
// \ \-\ \(\w{3}\)|\.|' =>
// \-\,\  => _
// \ =>
// \= =>  = 

// Format to Enum (Crystal)
// ==========================
// value = %()
// split = value.split("\n")
// list = [] of String

// split.each_with_index do |item, index|
//   list << String.build { |io| io << item << " = " << index << "_i32" }
// end

// list
// ==========================

// Define regions and list.
let regions = document.getElementsByClassName("component-container border-color is-group open");
let list = [];

// Put the result into the list.
for (let region of regions) {
  for (let location of region.children[1].children) {
    list.push(location.children[0].innerText);
  }
}

// Copy to clipboard.
copy(list);