# frozen_string_literal: true

# Script to create test users with invite relationships
# Run with: rails runner plugins/discourse-invite-stats/scripts/create-test-data.rb

puts "Creating test invite tree data..."

# Helper to create an invite and accepting user
def create_invited_user(username, email, inviter, options = {})
  # Create the invite first (if there's an inviter)
  invite = nil
  if inviter
    invite = Invite.create!(
      invited_by_id: inviter.id,
      email: email,
      max_redemptions_allowed: 1
    )
  end

  # Create the user
  user = User.create!(
    username: username,
    email: email,
    password: "TestPass123!@#",
    active: true,
    approved: true,
    trust_level: options[:trust_level] || rand(0..4),
    created_at: options[:created_at] || rand(1..365).days.ago
  )

  # Link the invite to the user (simulate redemption)
  if invite
    invite.update!(redemption_count: 1)
    InvitedUser.create!(
      user_id: user.id,
      invite_id: invite.id,
      redeemed_at: user.created_at
    )
  end

  # Add some random posts
  post_count = options[:post_count] || rand(5..20)
  post_count.times do
    PostCreator.create!(
      user,
      raw: "This is a test post from #{username}.",
      title: "Test Post from #{username}",
      category: Category.first&.id,
      skip_validations: true
    )
  end

  # Apply moderation actions if specified
  if options[:suspended]
    user.suspended_till = 1.year.from_now
    user.suspended_at = 1.day.ago
    user.save!
    puts "  ⚠️  Suspended #{username}"
  end

  if options[:silenced]
    user.silenced_till = 1.month.from_now
    user.save!
    puts "  ⚠️  Silenced #{username}"
  end

  # Add flags if specified
  if options[:flags_agreed] && options[:flags_agreed] > 0
    user_stat = UserStat.find_or_create_by(user_id: user.id)
    user_stat.update!(flags_agreed: options[:flags_agreed])
    puts "  ⚠️  Added #{options[:flags_agreed]} agreed flags to #{username}"
  end

  puts "  Created #{username} (invited by #{inviter&.username || 'none'})"
  user
end

# Clean up existing test users
puts "\nCleaning up existing test users..."
User.where("username LIKE 'test_%'").destroy_all

# Create founding members (no inviter) - good users
puts "\nCreating founding members..."
alice = create_invited_user("test_alice", "alice@example.com", nil)
bob = create_invited_user("test_bob", "bob@example.com", nil)
carol = create_invited_user("test_carol", "carol@example.com", nil)

# Alice's invites (mostly good, some problematic) - She'll have a poor quality score
puts "\nCreating Alice's invites..."
charlie = create_invited_user("test_charlie", "charlie@example.com", alice)
diana = create_invited_user("test_diana", "diana@example.com", alice, suspended: true) # Problematic
eve = create_invited_user("test_eve", "eve@example.com", alice, flags_agreed: 5) # Problematic
frank = create_invited_user("test_frank", "frank@example.com", alice, silenced: true) # Problematic
grace = create_invited_user("test_grace", "grace@example.com", alice)
henry = create_invited_user("test_henry", "henry@example.com", alice, flags_agreed: 4) # Problematic

# Bob's invites (all good) - He'll have 100% quality score
puts "\nCreating Bob's invites..."
iris = create_invited_user("test_iris", "iris@example.com", bob)
jack = create_invited_user("test_jack", "jack@example.com", bob)
kate = create_invited_user("test_kate", "kate@example.com", bob)
leo = create_invited_user("test_leo", "leo@example.com", bob)

# Carol's invites (mix of good and bad) - Moderate quality score
puts "\nCreating Carol's invites..."
maya = create_invited_user("test_maya", "maya@example.com", carol)
noah = create_invited_user("test_noah", "noah@example.com", carol, suspended: true) # Problematic
olivia = create_invited_user("test_olivia", "olivia@example.com", carol)
paul = create_invited_user("test_paul", "paul@example.com", carol, flags_agreed: 3) # Problematic
quinn = create_invited_user("test_quinn", "quinn@example.com", carol)

# Charlie's invites (second generation, mostly good)
puts "\nCreating Charlie's invites..."
rachel = create_invited_user("test_rachel", "rachel@example.com", charlie)
sam = create_invited_user("test_sam", "sam@example.com", charlie)
tina = create_invited_user("test_tina", "tina@example.com", charlie, flags_agreed: 2)

# Grace's invites (second generation, some problematic)
puts "\nCreating Grace's invites..."
uma = create_invited_user("test_uma", "uma@example.com", grace, suspended: true) # Problematic
victor = create_invited_user("test_victor", "victor@example.com", grace, silenced: true) # Problematic
wendy = create_invited_user("test_wendy", "wendy@example.com", grace, flags_agreed: 6) # Problematic

# Iris's invites (second generation, all good)
puts "\nCreating Iris's invites..."
xander = create_invited_user("test_xander", "xander@example.com", iris)
yara = create_invited_user("test_yara", "yara@example.com", iris)

# Maya's invites (second generation, mix)
puts "\nCreating Maya's invites..."
zack = create_invited_user("test_zack", "zack@example.com", maya)
amber = create_invited_user("test_amber", "amber@example.com", maya, flags_agreed: 4) # Problematic

# Rachel's invites (third generation)
puts "\nCreating Rachel's invites..."
blake = create_invited_user("test_blake", "blake@example.com", rachel)
casey = create_invited_user("test_casey", "casey@example.com", rachel, suspended: true) # Problematic

puts "\n✓ Test data created successfully!"
puts "\nInvite tree structure summary:"
puts "  Alice: 6 invites (4 problematic) - Will show in accountability report"
puts "  Bob: 4 invites (0 problematic) - 100% quality"
puts "  Carol: 5 invites (2 problematic) - Moderate quality"
puts "  Grace: 3 invites (3 problematic) - Will show in accountability report"
puts "  Rachel: 2 invites (1 problematic)"
puts "\nTotal users created: #{User.where("username LIKE 'test_%'").count}"
puts "\nProblematic users marked with suspensions, silences, or flags"
puts "View at: /invite-stats"
