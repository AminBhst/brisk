enum InternalMessage {
  OVERLAPPING_REFRESH_SEGMENT,
  REFRESH_SEGMENT_SUCCESS,
  REFRESH_SEGMENT_REFUSED,
  REUSE_CONNECTION__REFRESH_SEGMENT_REFUSED,
  REFRESH_SEGMENT_REQUEST_REFUSED,
}

InternalMessage message_refreshSegmentRefused(bool reuseConnection) {
  return reuseConnection
      ? InternalMessage.REUSE_CONNECTION__REFRESH_SEGMENT_REFUSED
      : InternalMessage.REFRESH_SEGMENT_REFUSED;
}
