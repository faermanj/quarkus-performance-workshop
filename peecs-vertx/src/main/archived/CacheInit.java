package caravanacloud;

import org.infinispan.Cache;
import org.infinispan.client.hotrod.RemoteCache;

import io.quarkus.infinispan.client.Remote;
import io.quarkus.logging.Log;
import io.quarkus.runtime.StartupEvent;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;

public class CacheInit {
    @Inject
    Cache<Integer, Cliente> members;

    public void init(@Observes StartupEvent e) {
        Log.info("CacheInit.init");
        var c1 = Cliente.of(1,100000,0);
        var c2 = Cliente.of(2, 80000, 0);
        var c3 = Cliente.of(3, 1000000, 0);
        var c4 = Cliente.of(4, 10000000, 0);
        var c5 = Cliente.of(5, 500000, 0);
        
        members.put(c1.id, c1);
        members.put(c2.id, c2);
        members.put(c3.id, c3);
        members.put(c4.id, c4);
        members.put(c5.id, c5);
    }
    
}
