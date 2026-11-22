package vn.iotstar;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;

public class MutableClock extends Clock {
    private Instant currentInstant;
    private final ZoneId zone;

    public MutableClock(Instant initialInstant, ZoneId zone) {
        this.currentInstant = initialInstant;
        this.zone = zone;
    }

    public MutableClock(long initialMillis) {
        this(Instant.ofEpochMilli(initialMillis), ZoneId.systemDefault());
    }

    public MutableClock() {
        this(Instant.now(), ZoneId.systemDefault());
    }

    public synchronized void advanceMillis(long millis) {
        this.currentInstant = this.currentInstant.plusMillis(millis);
    }

    public synchronized void advanceSeconds(long seconds) {
        advanceMillis(seconds * 1000L);
    }

    public synchronized void advanceMinutes(long minutes) {
        advanceMillis(minutes * 60_000L);
    }

    public synchronized void setMillis(long millis) {
        this.currentInstant = Instant.ofEpochMilli(millis);
    }

    @Override
    public ZoneId getZone() {
        return zone;
    }

    @Override
    public Clock withZone(ZoneId zone) {
        return new MutableClock(this.currentInstant, zone);
    }

    @Override
    public synchronized Instant instant() {
        return currentInstant;
    }

    @Override
    public synchronized long millis() {
        return currentInstant.toEpochMilli();
    }
}
