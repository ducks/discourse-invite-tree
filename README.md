# Discourse Invite Stats

A Discourse plugin that visualizes user invite relationships in a clean ASCII
tree format, showing how members invited each other to join the community.

![Invite Tree Screenshot](screenshot.png)

## Features

- Clean ASCII tree visualization (Lobsters-style)
- Shows invite hierarchy from founding members down through all generations
- Displays join dates and invite counts
- Handles both invite-only and open registration communities
- Simple, hackable design using monospace font and tree characters
- Fully responsive

## Installation

Add this repository URL to your Discourse plugin list in `app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/ducks/discourse-invite-stats.git
```

Then rebuild your container:

```bash
./launcher rebuild app
```

## Configuration

After installation, go to **Admin > Settings > Plugins > discourse-invite-stats**:

- `invite_stats_enabled`: Enable or disable the invite tree feature (default: false)
- `invite_stats_allowed_groups`: Groups allowed to view the invite tree (default: empty, allows all logged-in users, staff always have access)
- `invite_stats_show_stats`: Show user statistics in the tree (default: true)

### Access Control

By default, all logged-in users can view the invite tree. You can restrict access by:

1. Adding groups to the `invite_stats_allowed_groups` setting
2. Only users in those groups (or staff) will have access
3. Leave empty to allow all logged-in users

### Invite-Only Mode

To enable invite-only registration, use Discourse's native setting at **Admin >
Settings > Login**:

- `invite_only`: Restrict registration to invited users only

## Usage

Once enabled, the invite tree is accessible at `/invite-stats` on your forum.

The tree shows:
- Usernames with links to profiles
- Join dates
- Number of invites each user has made (in brackets)
- ASCII tree lines showing parent-child relationships
- Moderation indicators (suspended, silenced, flagged users)
- Invite quality scores for accountability

Users without an inviter (founding members or self-registered users) appear at
the root level.

### Moderation Features

The invite tree includes accountability metrics to help identify problematic
inviters:

- **Invite Quality Score**: Percentage of invites that didn't result in suspended/silenced/flagged users
- **Problematic Invites Count**: Number of invited users who were suspended, silenced, or have 3+ agreed flags
- **Problematic Inviters List**: Users who invited 3+ problematic users OR have <70% success rate with 5+ invites
- **Summary Statistics**: Overall invite success rates and totals

This data helps moderators identify users who consistently invite problematic
members and may need their invite privileges reviewed.

## How It Works

The plugin uses Discourse's native invite system:
- Queries the `invited_users` and `invites` tables
- Builds a recursive tree structure from invite relationships
- Displays only active, non-suspended users
- Root users are anyone without an inviter (founders or self-signups)

## Development

### Local Setup

1. Clone to your Discourse plugins directory:
   ```bash
   cd ~/discourse/plugins
   git clone https://github.com/ducks/discourse-invite-stats.git
   ```

2. Start your development Discourse instance

3. Enable the plugin in settings

### Test Data

Generate test invite tree data:

```bash
cd ~/discourse
bin/rails runner plugins/discourse-invite-stats/scripts/create-test-data.rb
```

This creates 16 test users with a 3-generation invite tree.

### File Structure

```
discourse-invite-stats/
├── plugin.rb                          # Main plugin file
├── config/
│   ├── locales/
│   │   ├── client.en.yml             # Frontend translations
│   │   └── server.en.yml             # Backend translations
│   └── settings.yml                   # Plugin settings
├── app/
│   ├── controllers/
│   │   └── invite_stats_controller.rb  # Backend API with recursive SQL
│   └── serializers/
│       └── invite_stats_serializer.rb  # JSON serialization
├── assets/
│   ├── javascripts/discourse/
│   │   ├── routes/invite-stats.js      # Route definition
│   │   ├── templates/invite-stats.gjs  # Main template
│   │   ├── components/
│   │   │   └── invite-tree-node.gjs   # Recursive tree node component
│   │   └── discourse-invite-stats-route-map.js
│   └── stylesheets/invite-stats.scss   # Minimal styling
└── scripts/
    └── create-test-data.rb            # Test data generator
```

## Customization

The plugin is designed to be easily customizable:

- **Styling**: Override `.invite-tree-node` CSS classes
- **Tree characters**: Modify `treePrefix` getter in `invite-tree-node.gjs`
- **Display format**: Edit the component template to show different data
- **Color scheme**: Uses Discourse CSS variables, adapts to themes automatically

## License

MIT

## Author

Jake Goldsborough

## Contributing

Issues and pull requests welcome!
