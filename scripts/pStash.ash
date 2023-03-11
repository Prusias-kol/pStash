script "pStash";
notify Coolfood;

string iotmFile = "data/pStash/sharedStashCounts.txt";
string cheapFile = "data/pStash/nonIotmSharedStashCounts.txt";
string personalFile = "data/pStash/personalStashOverlap.txt";

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
void goldHTMLprint(string text);
void printHelp();
void checkForUpdate();
void verifyStash();
void who_took(item it);
int totalItemAmount(item x);
void returnToStash();

void printHelp(){
    goldHTMLprint("<b>Welcome to pStash Stash Manager</b>");
    print_html("<b>init</b> - Initializes pStash. Must be run before any other functions will work. Be in the desired clan before running pStash.");
    print("Make sure you return all stash items before running init.", "red");
    print_html("<b>reset</b> - Resets pStash so you can run init again.");
    print_html("<b>list</b> - Lists tracked stash items and their amounts.");
    print_html("<b>verify</b> - If a stash item is missing, checks who last took it out.");
    print_html("<b>return</b> - Return stash items that you took out. Will not return your personal items");
}

void main(string option) {
    checkForUpdate();
    string [int] commands = option.split_string("\\s+");
    for(int i = 0; i < commands.count(); ++i){
        switch(commands[i]){
            case "init":
                if (!user_confirm("Are you in the desired clan and possess permissions to view clan stash logs?") )
                {
                abort("Script execution canceled by user.");
                }
                init();
                return;
            case "reset":
                if (!user_confirm("Are you sure you want to reset pStash? You will have to rerun init.") )
                {
                abort("Script execution canceled by user.");
                }
                set_property("prusias_pStash_clan", "");
            case "list":
                listStash();
                return;
            case "verify":
                verifyStash();
                return;
            case "return":
                returnToStash();
                return;
            case "help":
                printHelp();
                return;
            default:
                printHelp();
                return;
        }
    }
}

//assumes you nver take out items u personally own
void helperReturnItem(int[item] map, item it) {
    if (map contains it) {
        print("Skipping " + it + " because it's tracked as a personal item");
    } else {
        print("Returning " + it);
        cli_execute("stash put " + it);
    }
}

void returnToStash() {
    //grab personal list
    int [item] personalItemListFromFile;
    file_to_map(personalFile, personalItemListFromFile);
    //Iotm
    int [item] iotmStashList;
    file_to_map(iotmFile, iotmStashList);
    goldHTMLprint("<b>Returning Shareable Iotms in Stash</b>");
    foreach key in iotmStashList {
        if (totalItemAmount(key) > 0)
            helperReturnItem(personalItemListFromFile, key);
    }
    //Non-iotm
    int [item] cheapStashList;
    file_to_map(cheapFile, cheapStashList);
    goldHTMLprint("<b>Returning Shareable Non-Iotm Items in Stash</b>");
    foreach key in cheapStashList {
        if (totalItemAmount(key) > 0)
            helperReturnItem(personalItemListFromFile, key);
    }
}

boolean verifyInit() {
    if (get_property("prusias_pStash_clan") == "") {
        return false;
    } else {
        return true;
    }
}

void init() {
    goldHTMLprint("Intiating pStash...");
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
    foreach key in noniotm_items {
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
    //CHECK PERSONAL ITEMS
    int [item] initPersonalItemList;
    foreach key in valuable_items {
		if (totalItemAmount(key) > 0) {
			initPersonalItemList[key] = totalItemAmount(key);
		} 
	}
    foreach key in noniotm_items {
		if (totalItemAmount(key) > 0) {
			initPersonalItemList[key] = totalItemAmount(key);
		} 
	}
    if (map_to_file(initPersonalItemList, personalFile))
        print("File saved successfully.");
    else
        print("Error, file was not saved.");
    //set Clan
    set_property("prusias_pStash_clan", get_clan_name());
    goldHTMLprint("pStash has been initiated! Run pstash list to view the status!");
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
    goldHTMLprint("<b>Listing your personal items that overlap with the valuable stash item list:</b>");
    int [item] personalList;
    file_to_map(personalFile, personalList);
    foreach key in personalList {
		print("You own " + personalList[key] + " of " + key);
	}
}

void helperVerifyMap(int [item] map) {
    foreach key in map {
		if (map[key] > 0) {
            if (stash_amount(key) < map[key]) {
                //In the future, match multiple if multiple missing.
                // int i = map[key] - stash_amount(key) 
                // while (i > 0) {
                //     i = i -1;
                // }
                who_took(key);
            }
		} 
	}
}

void verifyStash() {
    if (!verifyInit()) {
        goldHTMLprint("<b>Please run pStash help to see how to initialize pStash</b>");
        return;
    }
    //Iotm
    int [item] iotmStashList;
    file_to_map(iotmFile, iotmStashList);
    goldHTMLprint("<b>Checking Shareable Iotms in Stash</b>");
    helperVerifyMap(iotmStashList);
    //Non-iotm
    int [item] cheapStashList;
    file_to_map(cheapFile, cheapStashList);
    goldHTMLprint("<b>Checking Shareable Non-Iotm Items in Stash</b>");
    helperVerifyMap(cheapStashList);
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

void goldHTMLprint(string text) {
    print_html("<font color=eda800>" + text + "</font>");
}

void checkForUpdate() {
    //itom list should never change
    int [item] cheapStashList;
    file_to_map(cheapFile, cheapStashList);
    foreach key in noniotm_items {
        if (!(cheapStashList contains key)) {
            print("Trackable valuable non-iotm item list has been updated! Consider resetting and running init!", "red");
        }
    }
}

//From Thoth
void who_took(item it) {
	string log = visit_url("clan_log.php");
	// 11/30/21, 07:01PM: CheeseyPickle (#3048851) took 1 picky tweezers.
	matcher item_matcher = create_matcher(">([^>]+ .#\\d+.)</a> (took 1 "+it.name+")", log);
	if (item_matcher.find()) {
		print("Player " + item_matcher.group(1) + " has the item: " + it.name);
	} else {
		print("Item Searcher Failed");
		//abort("dumb matcher");
	}
}

int totalItemAmount(item x) {
    return item_amount(x) + closet_amount(x) + display_amount(x) + equipped_amount(x) + shop_amount(x) + storage_amount(x);
}