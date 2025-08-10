# Wishlist Sharing Project

This project tracks tasks for enabling users to share their wishlists with others.

## Project Setup
- [ ] Create a GitHub project board named `wishlist-sharing` to manage the following tasks.

## Feature Tasks

### 1. Invitation Data Model
- [ ] Design Firestore structures to store wishlist invitations.
- [ ] Record owner, invited email, status, and related wishlist.
- [ ] Create `Invitation` model class in code.
- [ ] Define `/wishlistInvites` collection and document format.
- [ ] Add Firestore security rules for reading and writing invites.

### 2. Sending Invitations
- [ ] Build UI for owners to enter an email and send an invitation.
- [ ] Generate invitation links containing a secure token.
- [ ] Add service method to create invitation documents.
- [ ] Validate email address before sending.
- [ ] Trigger email delivery with the invitation link to the recipient.

### 3. Invitation Link Flow
- [ ] Create route to handle invitation links.
- [ ] Parse the token from the link and load the invitation.
- [ ] If the visitor is not authenticated, redirect to login or registration.
- [ ] After login/register, display the pending invitation.

### 4. Accepting or Rejecting Invitations
- [ ] Show invitation details and allow the user to accept or reject.
- [ ] When accepting, add the user as a wishlist member and mark invitation accepted.
- [ ] When rejecting, mark the invitation declined and hide future prompts.
- [ ] Display confirmation messages for accept and reject actions.

### 5. Membership Management
- [ ] When an invitation is accepted, add the user as a member of the wishlist.
- [ ] Update the owner's view to display current members.
- [ ] Load members list from Firestore in wishlist service.
- [ ] Allow owner to remove members from the wishlist.

### 6. Testing
- [ ] Unit tests for invitation model and service methods.
- [ ] Widget tests for invitation and membership UI.
- [ ] Integration tests covering the invite flow end to end.

