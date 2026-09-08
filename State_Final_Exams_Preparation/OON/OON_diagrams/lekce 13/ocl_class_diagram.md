# Class Diagram v OCL
## IoT Video Streaming System
```
┌─────────────────────────────────────┐
│         VideoStream                 │
├─────────────────────────────────────┤
│ - _video_provider: VideoProvider    │
│ - _frame_buffer: FrameBuffer        │
│ - _formatted_buffer: FrameBuffer    │
│ - _format_strategy: FormatterStrategy│
│ - _listeners: List<Listener>        │
│ - _buffer_size: Integer             │
│ - _thread_frequency: Real           │
├─────────────────────────────────────┤
│ + update(): void                    │
│ + add_listener(l: Listener): void   │
│ + remove_listener(l: Listener): void│
│ + release(): void                   │
└─────────────────────────────────────┘
```

## OCL Constraints pro VideoStream
### Invarianty (musí platit vždy):
```ocl
context VideoStream
-- Buffer size musí být kladný a rozumný
inv validBufferSize:
    self._buffer_size > 0 and self._buffer_size <= 100
-- Thread frequency musí být v rozumném rozsahu (30-60 FPS)
inv validThreadFrequency:
    self._thread_frequency >= 0.016 and self._thread_frequency <= 0.033
-- VideoStream musí mít právě jeden provider
inv hasProvider:
    self._video_provider <> null
-- Oba buffery musí mít stejnou kapacitu
inv buffersSameCapacity:
    self._frame_buffer.capacity = self._formatted_buffer.capacity
-- Buffery musí mít stejnou kapacitu jako buffer_size
inv bufferMatchesSize:
    self._frame_buffer.capacity = self._buffer_size
-- Listeners nesmí obsahovat duplicity
inv uniqueListeners:
    self._listeners->isUnique()
-- Pokud je format_strategy null, formatted_buffer by měl být prázdný
inv strategyImpliesFormatting:
    self._format_strategy = null implies 
    self._formatted_buffer->size() = 0
```

### Pre-conditions (před voláním metody):
```ocl
context VideoStream::add_listener(listener: VideoStreamListener)
-- Listener nesmí být null
pre listenerNotNull:
    listener <> null
-- Listener ještě není v seznamu
pre listenerNotExists:
    not self._listeners->includes(listener)
```

### Post-conditions (po volání metody):
```ocl
context VideoStream::add_listener(listener: VideoStreamListener)
-- Listener je v seznamu
post listenerAdded:
    self._listeners->includes(listener)
-- Počet listenerů se zvýšil o 1
post listenerCountIncreased:
    self._listeners->size() = self._listeners@pre->size() + 1
```

```
┌─────────────────────────────────────┐
│         FrameBuffer                 │
├─────────────────────────────────────┤
│ - capacity: Integer                 │
│ - frame_shape: Tuple                │
│ - frame_dtype: Type                 │
│ - buffer: Array                     │
│ - index: Integer                    │
│ - full: Boolean                     │
├─────────────────────────────────────┤
│ + add_frame(frame: ndarray): void   │
│ + get(i: Integer): ndarray          │
│ + size(): Integer                   │
└─────────────────────────────────────┘
```

## OCL Constraints pro FrameBuffer
```ocl
context FrameBuffer
-- Kapacita musí být kladná
inv positiveCapacity:
    self.capacity > 0
-- Index musí být v rozsahu [0, capacity)
inv validIndex:
    self.index >= 0 and self.index < self.capacity

-- Full flag odpovídá stavu bufferu
inv fullFlagConsistent:
    self.full = (self.buffer->size() = self.capacity)

-- Buffer nesmí přesáhnout kapacitu
inv bufferNotOverflow:
    self.buffer->size() <= self.capacity

-- Pokud není full, index odpovídá velikosti
inv indexConsistency:
    not self.full implies self.index = self.buffer->size()
```

```ocl
context FrameBuffer::add_frame(frame: ndarray)

-- Frame nesmí být null
pre frameNotNull:
    frame <> null

-- Frame musí mít správný tvar
pre frameShapeMatch:
    frame.shape = self.frame_shape

-- Po přidání se index zvýší (pokud není full) nebo se zarotuje
post indexUpdated:
    self.index = (self.index@pre + 1) mod self.capacity

-- Pokud buffer nebyl full a ještě není plný, velikost se zvýší
post sizeIncreased:
    not self@pre.full and self.buffer->size() < self.capacity
    implies self.buffer->size() = self.buffer@pre->size() + 1
```

```ocl
context FrameBuffer::get(i: Integer): ndarray

-- Index musí být platný
pre validGetIndex:
    if self.full then
        i >= 0 and i < self.capacity
    else
        i >= 0 and i < self.buffer->size()
    endif

-- Vrací nenullový frame
post frameReturned:
    result <> null
```

---

```
┌─────────────────────────────────────┐
│    <<abstract>>                     │
│    VideoProvider                    │
├─────────────────────────────────────┤
│ + read(): Tuple<Boolean, ndarray>   │
│ + get_name(): String                │
│ + is_active(): Boolean              │
│ + release(): void                   │
└─────────────────────────────────────┘
         △
         │
    ┌────┴────┬──────────┬──────────┐
    │         │          │          │
┌───┴───┐ ┌──┴────┐ ┌───┴────┐ ┌──┴─────┐
│Camera │ │ File  │ │YouTube │ │  RPI   │
│Provider│ │Provider│ │Provider│ │Provider│
└───────┘ └───────┘ └────────┘ └────────┘
```

## OCL Constraints pro VideoProvider

```ocl
context VideoProvider

-- Pokud je provider aktivní, read() musí vracet platná data
inv activeImpliesData:
    self.is_active() implies 
    self.read().first = true and self.read().second <> null

-- Název provideru nesmí být prázdný
inv nameNotEmpty:
    self.get_name() <> null and self.get_name().size() > 0
```

```ocl
context CameraVideoProvider

-- Camera ID musí být nezáporné
inv validCameraId:
    self.camera_id >= 0

-- Pokud je kamera aktivní, VideoCapture objekt není null
inv activeCapNotNull:
    self.is_active() implies self.cap <> null
```

```ocl
context RemoteRaspberryPiCameraProvider

-- IP adresa musí být validní formát
inv validIpFormat:
    self.raspberry_ip.matches('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')

-- Port musí být v rozsahu
inv validPort:
    self.stream_port > 0 and self.stream_port <= 65535

-- Rozlišení musí být rozumné
inv validResolution:
    self.resolution.width >= 640 and self.resolution.width <= 4096 and
    self.resolution.height >= 480 and self.resolution.height <= 2160

-- Framerate musí být rozumný
inv validFramerate:
    self.framerate >= 1 and self.framerate <= 120

-- SSH connection vyžaduje buď heslo nebo klíč
inv authenticationProvided:
    (self.raspberry_password <> null and self.raspberry_password <> '') or
    (self.ssh_key_path <> null and self.ssh_key_path <> '')
```

---

```
┌─────────────────────────────────────┐
│    <<abstract>>                     │
│ VideoStreamFormatterStrategy        │
├─────────────────────────────────────┤
│ - next: FormatterStrategy           │
├─────────────────────────────────────┤
│ + apply(frame, stream): ndarray     │
│ + format(frame, stream): ndarray    │
│ + append_chain(strategy): void      │
└─────────────────────────────────────┘
         △
         │
    ┌────┴────┬──────────┐
    │         │          │
┌───┴────┐ ┌─┴────┐ ┌───┴────────┐
│ Resize │ │Gray  │ │   Custom   │
│Strategy│ │Scale │ │  Strategy  │
└────────┘ └──────┘ └────────────┘
```

## OCL Constraints pro FormatterStrategy

```ocl
context VideoStreamFormatterStrategy

-- Chain nesmí vytvořit cyklus
inv noCycles:
    not self.allNext()->includes(self)

-- Helper operace pro získání všech next strategií
def: allNext(): Set(VideoStreamFormatterStrategy) =
    if self.next = null then
        Set{}
    else
        Set{self.next}->union(self.next.allNext())
    endif

-- Apply musí volat format
inv applyCallsFormat:
    self.apply(frame, stream) = 
    if self.next = null then
        self.format(frame, stream)
    else
        self.next.apply(self.format(frame, stream), stream)
    endif
```

```ocl
context _ResizeStrategy

-- Velikost musí být kladná
inv validSize:
    self.size.width > 0 and self.size.height > 0

-- Rozumná maximální velikost
inv reasonableSize:
    self.size.width <= 4096 and self.size.height <= 4096

-- Interpolation musí být validní hodnota
inv validInterpolation:
    Set{0, 1, 2, 3, 4}->includes(self.interpolation)
```

---

```
┌─────────────────────────────────────┐
│    <<abstract>>                     │
│   VideoStreamListener               │
├─────────────────────────────────────┤
│ + on_frame(frame, formatted,        │
│            stream): void            │
└─────────────────────────────────────┘
         △
         │
    ┌────┴────┐
    │         │
┌───┴────┐ ┌─┴──────┐
│  RTPS  │ │   UI   │
│ Stream │ │Listener│
└────────┘ └────────┘
```

## OCL Constraints pro Listener

```ocl
context RTPSStream

-- RTP adresa musí mít správný formát
inv validRtpAddress:
    self.rtp_address.startsWith('rtp://') or
    self.rtp_address.startsWith('rtsp://')

-- Stream musí být přiřazen
inv streamAssigned:
    self.stream <> null

-- Writer musí být inicializován před použitím
inv writerInitialized:
    self.isActive() implies self.writer <> null
```

---

## Globální OCL Constraints

```ocl
-- Všechny VideoStreamy musí mít unikátní providery
context VideoStream
inv uniqueProviders:
    VideoStream.allInstances()->forAll(vs1, vs2 |
        vs1 <> vs2 implies vs1._video_provider <> vs2._video_provider
    )

-- Maximální počet aktivních streamů
context VideoStream
inv maxActiveStreams:
    VideoStream.allInstances()
        ->select(vs | vs._video_provider.is_active())
        ->size() <= 10

-- FrameBuffer capacity napříč všemi instancemi
context FrameBuffer
inv reasonableGlobalCapacity:
    FrameBuffer.allInstances()
        ->collect(capacity)
        ->sum() <= 1000
```

---

## Derived Attributes (odvozené atributy)

```ocl
context VideoStream

-- Celkový počet uložených snímků
def: totalFrames(): Integer =
    self._frame_buffer->size() + self._formatted_buffer->size()

-- Je stream aktivní?
def: isActive(): Boolean =
    self._video_provider.is_active()

-- Průměrná velikost framu v bytech
def: avgFrameSize(): Real =
    if self._frame_buffer->size() > 0 then
        self._frame_buffer->collect(f | f.nbytes)->sum() / 
        self._frame_buffer->size()
    else
        0.0
    endif
```

```ocl
context FrameBuffer

-- Procento zaplnění bufferu
def: fillPercentage(): Real =
    (self.buffer->size() / self.capacity) * 100.0

-- Je buffer prázdný?
def: isEmpty(): Boolean =
    self.buffer->size() = 0
```

---

## Příklady dotazů (Queries)

```ocl
-- Všechny aktivní VideoStreamy
VideoStream.allInstances()
    ->select(vs | vs.isActive())

-- VideoStreamy s více než 5 listenery
VideoStream.allInstances()
    ->select(vs | vs._listeners->size() > 5)

-- Všechny FrameBuffery, které jsou plné
FrameBuffer.allInstances()
    ->select(fb | fb.full)

-- Providery typu CameraVideoProvider
VideoProvider.allInstances()
    ->select(vp | vp.oclIsTypeOf(CameraVideoProvider))

-- Celkový počet listenerů ve všech streamech
VideoStream.allInstances()
    ->collect(_listeners)
    ->flatten()
    ->size()

-- Průměrná kapacita bufferů
FrameBuffer.allInstances()
    ->collect(capacity)
    ->sum() / FrameBuffer.allInstances()->size()
```
