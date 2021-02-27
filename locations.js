// References: https://www.cloudflarestatus.com/
// Written in: Thursday, February 25, 2021
// Executed every six months, Cloudflare will add new location Edge servers from time to time.
// We need to stay in sync.

// Regular Expression (Sublime)
// IATA Regular expression: (.*?\()(\w+)(.*) => \1
// Edge Regular expression: -> {
// -> (  \")(.*?)( \-[\ \ ]+.*) => \2
// -> (.*?), (.*?), (.*) => \1_\3
// -> ,\ => _
// -> \  =>
// -> [\.\']+ =>
// }

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

// Position Anchor point.
let regionsSections = document.getElementsByClassName('regions-section font-regular');

// The first section is the Cloudflare system state, which is useless to us, we remove it.
regionsSections[0].children[0].children[0].remove();

// Define regionsSectionsRootNode and list.
let regionsSectionsRootNode = regionsSections[0].children[0].children;
let list = [];

// Put the result into the list.
for (let region of regionsSectionsRootNode) {
	for (let cityRootNode of region.children[1].children) {
		list.push(cityRootNode.children[0].innerText);
	}
}

// Copy to clipboard.
copy(list);