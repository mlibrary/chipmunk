import React from "react";
import ArtifactView from "../artifact_view";
import {render, cleanup} from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";

let doc;

afterEach(() => {
  cleanup();
  fetch.resetMocks();
});

describe('<ArtifactView/>', () => {
  beforeEach(() => {
    doc = render(
      <MemoryRouter>
        <ArtifactView/>
      </MemoryRouter>
    );
  });

  it("has no content", () => {
    expect(doc.baseElement.innerHTML).not.toMatch(/>[^<]/);
  });

  it("doesn't call fetch()", () => {
    expect(fetch.mock.calls.length).toEqual(0);
  });
});

describe('<ArtifactView error="A pretty bad problem"/>', () => {
  beforeEach(() => {
    doc = render(
      <MemoryRouter>
        <ArtifactView error="A pretty bad problem"/>
      </MemoryRouter>
    );
  });

  it('contains the text "A pretty bad problem"', () => {
    expect(doc.baseElement.innerHTML).toMatch(/A pretty bad problem/);
  });
});

describe('<ArtifactView id="foo"/>', () => {
  beforeEach(() => {
    fetch.mockResponseOnce();
    doc = render(
      <MemoryRouter>
        <ArtifactView id="foo"/>
      </MemoryRouter>
    );
  });

  it('should call fetch("v1/bags/foo")', () => {
    expect(fetch.mock.calls.length).toEqual(1);
    expect(fetch.mock.calls[0][0]).toEqual("v1/bags/foo");
  });
});

describe('<ArtifactView id="a 404ing artifact"/>', () => {
  let error;
  const setError = e => { error = e; };

  beforeEach(() => {
    fetch.mockResponseOnce('Not found', { status: 404 });
    doc = render(
      <MemoryRouter>
        <ArtifactView id="notfound" onError={e => { setError(e); }}/>
      </MemoryRouter>
    );
  });

  it('triggers its onError with 404', () => {
    expect(error).toEqual(404);
  });

  it("has no content", () => {
    expect(doc.baseElement.innerHTML).not.toMatch(/>[^<]/);
  });
});

describe('<ArtifactView id="a 403ing artifact"/>', () => {
  let error;
  const setError = e => { error = e; };

  beforeEach(() => {
    fetch.mockResponseOnce('Forbidden', { status: 403 });
    doc = render(
      <MemoryRouter>
        <ArtifactView id="forbidden" onError={e => { setError(e); }}/>
      </MemoryRouter>
    );
  });

  it('triggers its onError with 403', () => {
    expect(error).toEqual(403);
  });
});

describe('<ArtifactView id="a 501ing artifact"/>', () => {
  let error;
  const setError = e => { error = e; };

  beforeEach(() => {
    fetch.mockResponseOnce('Internal error', { status: 501 });
    doc = render(
      <MemoryRouter>
        <ArtifactView id="internal" onError={e => { setError(e); }}/>
      </MemoryRouter>
    );
  });

  it('triggers its onError with 501', () => {
    expect(error).toEqual(501);
  });
});

describe('<ArtifactView id="an artifact returning garbage json"/>', () => {
  let error;
  const setError = e => { error = e; };

  beforeEach(() => {
    fetch.mockResponseOnce('{{{{{{{{{{');
    doc = render(
      <MemoryRouter>
        <ArtifactView id="badjson" onError={e => { setError(e); }}/>
      </MemoryRouter>
    );
  });

  it('triggers its onError with 501', () => {
    expect(error).toEqual(501);
  });
});

describe('<ArtifactView id="an artifact with only a mets.xml file"/>', () => {
  let error;
  const setError = e => { error = e; };

  beforeEach(() => {
    fetch.mockResponseOnce(JSON.stringify({ files: ["mets.xml"],
                                            bag_id: "uuid" }));
    doc = render(
      <MemoryRouter>
        <ArtifactView id="justmets" onError={e => { setError(e); }}/>
      </MemoryRouter>
    );
  });

  it("doesn't trigger its onError", () => {
    expect(error).toBeUndefined();
  });

  it("should contain a link to that mets.xml file", () => {
    let count = 0;
    const elts = doc.baseElement.getElementsByTagName("a");

    for(let i = 0; i < elts.length; i += 1) {
      if(elts.item(i).getAttribute("href") === "v1/packages/uuid/mets.xml") {
        count += 1;
      }
    }

    expect(count).toEqual(1);
  });

  it("has no permalink", () => {
    expect(doc.baseElement.innerHTML).not.toMatch(/permalink/i);
  });
});

describe('<ArtifactView id="an artifact with five wav files"/>', () => {
  beforeEach(() => {
    fetch.mockResponseOnce(JSON.stringify({ files: ["00000001.wav",
                                                    "00000002.wav",
                                                    "00000003.wav",
                                                    "00000004.wav",
                                                    "00000005.wav",
                                                    "mets.xml"],
                                            bag_id: "it5" }));
    doc = render(
      <MemoryRouter>
        <ArtifactView id="fivewavs"/>
      </MemoryRouter>
    );
  });

  for(let wav = 1; wav <= 5; wav += 1) {
    let href = "0000000" + wav + ".wav";
    it("should contain a link to " + href, () => {
      let count = 0;
      const elts = doc.baseElement.getElementsByTagName("a");

      for(let i = 0; i < elts.length; i += 1) {
        if(elts.item(i).getAttribute("href") === "v1/packages/it5/" + href) {
          count += 1;
        }
      }

      expect(count).toEqual(1);
    });
  }
});

describe('<ArtifactView api="https://default.invalid/"/>', () => {
  beforeEach(() => {
    fetch.mockResponseOnce(JSON.stringify({ files: ["mets.xml"],
                                            bag_id: "uuid" }));
    doc = render(
      <MemoryRouter>
        <ArtifactView id="someid" api="https://default.invalid/"/>
      </MemoryRouter>
    );
  });

  it('should call fetch from https://default.invalid', () => {
    expect(fetch.mock.calls.length).toEqual(1);
    expect(fetch.mock.calls[0][0]).toEqual("https://default.invalid/v1/bags/someid");
  });

  it("should contain links to files under https://default.invalid", () => {
    let count = 0;
    const elts = doc.baseElement.getElementsByTagName("a");

    for(let i = 0; i < elts.length; i += 1) {
      if(elts.item(i).getAttribute("href") === "https://default.invalid/v1/packages/uuid/mets.xml") {
        count += 1;
      }
    }

    expect(count).toEqual(1);
  });
});

describe('<ArtifactView id="something"/> in a component that will rerender it a few times', () => {
  class OuterContainer extends React.Component {
    constructor(props) {
      super(props);
      this.state = { renderCount: 1 };
    }

    render() {
      // This will rerender before it has a chance to put itself in an
      // error state.
      return (
        <ArtifactView id="something" onError={e => { this.rerender(); }}/>
      );
    }

    rerender() {
      if (this.state.renderCount < 3) {
        this.setState({ renderCount: this.state.renderCount + 1 });
      }
    }
  }

  beforeEach(() => {
    fetch.mockResponseOnce();
    doc = render(
      <MemoryRouter>
        <OuterContainer/>
      </MemoryRouter>
    );
  });

  it("calls fetch only once", () => {
    expect(fetch.mock.calls.length).toEqual(1);
  });
});

describe('<ArtifactView permalink="/some/path/"/>', () => {
  beforeEach(() => {
    fetch.mockResponseOnce(JSON.stringify({ files: ["mets.xml"],
                                            bag_id: "uuid" }));
    doc = render(
      <MemoryRouter>
        <ArtifactView permalink="/some/path/" id="justmets"/>
      </MemoryRouter>
    );
  });

  it("shows the permalink", () => {
    let count = 0;
    const elts = doc.baseElement.getElementsByTagName("a");

    for(let i = 0; i < elts.length; i += 1) {
      if(elts.item(i).getAttribute("href") === "/some/path/justmets") {
        count += 1;
      }
    }

    expect(count).toEqual(1);
  });
});
