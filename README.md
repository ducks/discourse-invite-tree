# Discourse Invite Tree

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
          - git clone https://github.com/ducks/discourse-invite-tree.git
```

Then rebuild your container:

```bash
./launcher rebuild app
```

## Configuration

After installation, go to **Admin > Settings > Plugins > discourse-invite-tree**:

- `invite_tree_enabled`: Enable or disable the invite tree feature (default: false)

## Usage

Once enabled, the invite tree is accessible at `/invites/tree` on your forum.

The tree shows:
- Usernames with links to profiles
- Join dates
- Number of invites each user has made (in brackets)
- ASCII tree lines showing parent-child relationships

Users without an inviter (founding members or self-registered users) appear at
the root level.

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
   git clone https://github.com/ducks/discourse-invite-tree.git
   ```

2. Start your development Discourse instance

3. Enable the plugin in settings

### Test Data

Generate test invite tree data:

```bash
cd ~/discourse
bin/rails runner plugins/discourse-invite-tree/scripts/create-test-data.rb
```

This creates 16 test users with a 3-generation invite tree.

### File Structure

```
discourse-invite-tree/
├── plugin.rb                          # Main plugin file
├── config/
│   ├── locales/
│   │   ├── client.en.yml             # Frontend translations
│   │   └── server.en.yml             # Backend translations
│   └── settings.yml                   # Plugin settings
├── app/
│   ├── controllers/
│   │   └── invite_tree_controller.rb  # Backend API with recursive SQL
│   └── serializers/
│       └── invite_tree_serializer.rb  # JSON serialization
├── assets/
│   ├── javascripts/discourse/
│   │   ├── routes/invite-tree.js      # Route definition
│   │   ├── templates/invite-tree.gjs  # Main template
│   │   ├── components/
│   │   │   └── invite-tree-node.gjs   # Recursive tree node component
│   │   └── discourse-invite-tree-route-map.js
│   └── stylesheets/invite-tree.scss   # Minimal styling
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
