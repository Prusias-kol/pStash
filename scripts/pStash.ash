script "pStash";
notify Coolfood;

import <clan_stash.ash>

boolean [item] valuable_items = $items[platinum yendorian express card, moveable feast, pantsgiving, operation patriot shield, Buddy Bjorn, Crown of Thrones, Repaid Diaper, spooky putty sheet, origami pasties];


boolean verifyInit();

boolean verifyInit() {
  if (get_property("prusias_pStash_clan") == "") {
    print("Please run pstash init to setup pstash!", "red");
    abort();
  } else {
      return true;
  }
}

void init() {
  verifyInit();
  set_property("prusias_pStash_clan", get_clan_name());
  
  foreach it in it_lst {
		if (in_stash) {
			all = false;
		}
	}
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
