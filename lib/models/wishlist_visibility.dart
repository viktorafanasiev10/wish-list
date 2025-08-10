enum WishlistVisibility {
  private,       // only owner + explicitly invited
  inviteOnly,    // join by invite only (no open link)
  link,          // anyone with link can request/join (owner can auto-accept later)
  public,        // discoverable (future: public directory)
}