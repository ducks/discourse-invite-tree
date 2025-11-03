# frozen_string_literal: true

# Script to create test users with invite relationships
# Run with: rails runner plugins/discourse-invite-tree/scripts/create-test-data.rb

puts "Creating test invite tree data..."

# Helper to create an invite and accepting user
def create_invited_user(username, email, inviter)
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
    trust_level: rand(0..4),
    created_at: rand(1..365).days.ago
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
  rand(5..20).times do
    PostCreator.create!(
      user,
      raw: "This is a test post from #{username}.",
      title: "Test Post from #{username}",
      category: Category.first&.id,
      skip_validations: true
    )
  end

  puts "  Created #{username} (invited by #{inviter&.username || 'none'})"
  user
end

# Clean up existing test users
puts "\nCleaning up existing test users..."
User.where("username LIKE 'test_%'").destroy_all

# Create founding members (no inviter)
puts "\nCreating founding members..."
alice = create_invited_user("test_alice", "alice@example.com", nil)
bob = create_invited_user("test_bob", "bob@example.com", nil)

# Alice's invites (first generation)
puts "\nCreating Alice's invites..."
charlie = create_invited_user("test_charlie", "charlie@example.com", alice)
diana = create_invited_user("test_diana", "diana@example.com", alice)
eve = create_invited_user("test_eve", "eve@example.com", alice)

# Bob's invites (first generation)
puts "\nCreating Bob's invites..."
frank = create_invited_user("test_frank", "frank@example.com", bob)
grace = create_invited_user("test_grace", "grace@example.com", bob)

# Charlie's invites (second generation)
puts "\nCreating Charlie's invites..."
henry = create_invited_user("test_henry", "henry@example.com", charlie)
iris = create_invited_user("test_iris", "iris@example.com", charlie)

# Diana's invites (second generation)
puts "\nCreating Diana's invites..."
jack = create_invited_user("test_jack", "jack@example.com", diana)

# Frank's invites (second generation)
puts "\nCreating Frank's invites..."
kate = create_invited_user("test_kate", "kate@example.com", frank)
leo = create_invited_user("test_leo", "leo@example.com", frank)
maya = create_invited_user("test_maya", "maya@example.com", frank)

# Henry's invites (third generation)
puts "\nCreating Henry's invites..."
noah = create_invited_user("test_noah", "noah@example.com", henry)
olivia = create_invited_user("test_olivia", "olivia@example.com", henry)

# Kate's invites (third generation)
puts "\nCreating Kate's invites..."
paul = create_invited_user("test_paul", "paul@example.com", kate)

puts "\n✓ Test data created successfully!"
puts "\nInvite tree structure:"
puts "  Founding Members:"
puts "    - Alice (invited Charlie, Diana, Eve)"
puts "      └─ Charlie (invited Henry, Iris)"
puts "         └─ Henry (invited Noah, Olivia)"
puts "      └─ Diana (invited Jack)"
puts "    - Bob (invited Frank, Grace)"
puts "      └─ Frank (invited Kate, Leo, Maya)"
puts "         └─ Kate (invited Paul)"
puts "\nTotal users created: #{User.where("username LIKE 'test_%'").count}"
puts "\nView at: /invites/tree"
