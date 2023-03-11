script "pStash";
notify Coolfood;

string iotmFile = "data/pStash/sharedStashCounts.txt";
string cheapFile = "data/pStash/nonIotmSharedStashCounts.txt";

/* NonGarbo things added
- portable Mayo Clinic
- Little Geneticist DNA-Splicing Lab
*/
boolean [item] valuable_items = $items[snow suit, platinum yendorian express card, moveable feast, pantsgiving, operation patriot shield, Buddy Bjorn, Crown of Thrones, Repaid Diaper, spooky putty sheet, origami pasties, navel ring of navel gazing, mayflower bouquet, BittyCar MeatCar, BittyCar SoulCar, defective Game Grid token,
haiku katana, Bag o' Tricks, Greatest American Pants, portable Mayo Clinic, Little Geneticist DNA-Splicing Lab];
/* Non iotms shareables tracked
- chroner trigger
- chroner cross
- portable steam unit
*/
boolean [item] noniotm_items = $items[ chroner cross, chroner trigger, portable steam unit];


boolean verifyInit();
void init();
void listStash();
boolean in_stash(item it);
goldHTMLprint(string text);
void printHelp();

boolean verifyInit() {
    if (get_property("prusias_pStash_clan") == "") {
        return false;
    } else {
        return true;
    }
}

void init() {
    if (verifyInit()) {
        goldHTMLprint("pStash already iniated. Please reset before running init again.");
        return;
    }
    //CHECK IOTM ITEMS
    int [item] iotmStashList;
    //Does item exist in stash
    foreach key in valuable_items {
		if (in_stash(key) || stash_amount(key) > 0) {
			iotmStashList[key] = max(1, stash_amount(key));
		} else {
            iotmStashList[key] = 0;
        }
	}
    if (map_to_file(iotmStashList, iotmFile))
        print("File saved successfully.");
    else
        print("Error, file was not saved.");
    //CHECK NON IOTM ITEMS
    int [item] cheapStashList;
    //Does item exist in stash
    foreach key in valuable_items {
		if (in_stash(key) || stash_amount(key) > 0) {
			cheapStashList[key] = max(1, stash_amount(key));
		} else {
            cheapStashList[key] = 0;
        }
	}
    if (map_to_file(cheapStashList, cheapFile))
        print("File saved successfully.");
    else
        print("Error, file was not saved.");
    //set Clan
    set_property("prusias_pStash_clan", get_clan_name());
}

//helper
void listIterateMap(string msg1, string msg2, int [item] map) {
    print(msg1, "green");
    foreach key in map {
		if (map[key] > 0) {
            if (stash_amount(key) > map[key])
                print("- " + key + " has " + stash_amount(key) + "/" + map[key] + ". More exist in stash than logged!", "red");
            else
			    print("- " + key + " has " + stash_amount(key) + "/" + map[key]);
		} 
	}
    print(msg2, "red");
    foreach key in map {
		if (map[key] == 0) {
            if (stash_amount(key) > 0)
                print("- " + key + " has " + stash_amount(key) + " in stash. More exist in stash than logged!", "green");
            else
			    print("- " + key + " does not exist in stash.");
		} 
	}
}

void listStash() {
    if (!verifyInit()) {
        goldHTMLprint("<b>Please run pStash help to see how to initialize pStash</b>");
        return;
    }
    int [item] iotmStashList;
    file_to_map(iotmFile, iotmStashList);
    goldHTMLprint("<b>Checking Shareable Iotms in Stash</b>");
    listIterateMap("Currently Stashed Iotms:", "Shareable Iotms not in Stash:", iotmStashList);
    int [item] cheapStashList;
    file_to_map(cheapFile, cheapStashList);
    goldHTMLprint("<b>Checking Shareable Non-Iotm Items in Stash</b>");
    listIterateMap("Currently Stashed Non-Iotm Items:", "Shareable Non-Iotm Items not in Stash:", cheapStashList);
}

void verifyStash() {
    if (!verifyInit()) {
        goldHTMLprint("<b>Please run pStash help to see how to initialize pStash</b>");
        return;
    }
    int [item] iotmStashList;
    file_to_map(iotmFile, iotmStashList);
    goldHTMLprint("<b>Checking Shareable Iotms in Stash</b>");

}

boolean in_stash(item it) {
	string log = visit_url("clan_log.php");
	// 11/30/21, 07:01PM: CheeseyPickle (#3048851) took 1 picky tweezers.
	matcher item_matcher = create_matcher(">([^>]+ .#\\d+.)</a> (took 1 "+it.name+")", log);
	if (item_matcher.find()) {
		return true;
	} else {
		return false;
	}
}

void main(string option) {
    string [int] commands = option.split_string("\\s+");
    for(int i = 0; i < commands.count(); ++i){
        switch(commands[i]){
            case "init":
                if (!user_confirm("Are you in the desired clan and possess permissions to view clan stash logs?") )
                {
                abort("Script execution canceled by user.");
                }
                init();
                return();
            case "help":
                printHelp();
                return;
            default:
                printHelp();
                return;
        }
    }
}

void goldHTMLprint(string text) {
    print_html("<font color=0000ff>" + text + "</font>");
}