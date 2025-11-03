# Discourse Invite Tree

A Discourse plugin that visualizes your community's invite relationships as a hierarchical tree, showing who invited whom. Also supports invite-only registration mode.

## Features

- **Public Invite Tree**: View how members joined your community in an interactive hierarchical tree
- **User Information**: Display usernames, avatars, join dates, trust levels, and post counts
- **Expandable Nodes**: Click to expand/collapse branches of the invite tree
- **Invite-Only Mode**: Optional setting to restrict registration to invited users only
- **Responsive Design**: Works on desktop and mobile devices

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

### Settings

- **invite_tree_enabled**: Enable or disable the invite tree feature
- **invite_tree_registration_mode**:
  - `off`: Normal Discourse registration
  - `invite_only`: Only users with invites can register
- **invite_tree_show_stats**: Show user statistics (trust level, post count) in the tree

## Usage

Once enabled, the invite tree is accessible at `/invites/tree` on your forum.

### For Site Owners

1. Enable the plugin in settings
2. (Optional) Enable invite-only mode
3. Share the `/invites/tree` URL with your community

### For Users

- Navigate to `/invites/tree` to view the community invite structure
- Click on usernames to view profiles
- Click expand/collapse buttons to navigate branches
- See who invited whom and when they joined

## How It Works

The plugin:
- Uses Discourse's existing `invited_users` table to build relationships
- Constructs a tree from parent-child invite relationships
- Displays users who joined without invites as "Founding Members"
- Shows active, non-suspended users only

## Development

### Local Setup

1. Clone to your Discourse plugins directory:
   ```bash
   cd ~/discourse/plugins
   git clone https://github.com/ducks/discourse-invite-tree.git
   ```

2. Start your development Discourse instance

3. Enable the plugin in settings

### File Structure

```
discourse-invite-tree/
├── plugin.rb                          # Main plugin file
├── config/
│   ├── locales/client.en.yml         # Translations
│   └── settings.yml                   # Plugin settings
├── app/
│   ├── controllers/
│   │   └── invite_tree_controller.rb  # Backend API
│   └── serializers/
│       └── invite_tree_serializer.rb  # Data formatting
└── assets/
    ├── javascripts/discourse/
    │   ├── routes/invite-tree.js      # Ember route
    │   ├── templates/invite-tree.hbs   # Main template
    │   ├── components/
    │   │   └── invite-tree-node.gjs   # Tree node component
    │   └── discourse-invite-tree-route-map.js
    └── stylesheets/invite-tree.scss    # Styles
```

## License

MIT

## Author

Jake Goldsborough

## Contributing

Issues and pull requests welcome!
