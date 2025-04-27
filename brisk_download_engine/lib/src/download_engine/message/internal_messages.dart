enum InternalMessage {
  overlappingRefreshSegment,
  refreshSegmentSuccess,
  refreshSegmentRefused,
  reuseConnectionRefreshSegmentRefused,
  refreshSegmentRequestRefused,
}

InternalMessage messageRefreshSegmentRefused(bool reuseConnection) {
  return reuseConnection
      ? InternalMessage.reuseConnectionRefreshSegmentRefused
      : InternalMessage.refreshSegmentRefused;
}
