import React from "react";
import ArtifactSearch from "../artifact_search";
import {render, fireEvent, cleanup} from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";

let doc;

const searchField = () => doc.baseElement.getElementsByTagName("input").item(0);
const fireSearch = query => {
  fireEvent.change(searchField(), { target: { value: query } });
  fireEvent.submit(doc.baseElement.getElementsByTagName("form").item(0), {});
};

afterEach(() => {
  cleanup();
  fetch.resetMocks();
});

describe('<ArtifactSearch/>', () => {
  beforeEach(() => {
    doc = render(
      <MemoryRouter>
        <ArtifactSearch/>
      </MemoryRouter>
    );
  });

  it("creates an empty text input", () => {
    expect(searchField().getAttribute("type")).toEqual("text");
    expect(searchField().getAttribute("value")).toEqual("");
  });

  it('should call fetch("v1/bags/foo") when the user types in "foo"', () => {
    fetch.mockResponseOnce();
    fireSearch("foo");
    expect(fetch.mock.calls.length).toEqual(1);
    expect(fetch.mock.calls[0][0]).toEqual("v1/bags/foo");
  });

  it('should call fetch("v1/bags/bar") when the user types in "bar"', () => {
    fetch.mockResponseOnce();
    fireSearch("bar");
    expect(fetch.mock.calls.length).toEqual(1);
    expect(fetch.mock.calls[0][0]).toEqual("v1/bags/bar");
  });

  describe("when searching for a 404ing artifact", () => {
    beforeEach(() => {
      fetch.mockResponseOnce('Not found', { status: 404 });
      fireSearch("wrong_id")
    });

    it("displays an error message saying we can't find it", () => {
      expect(doc.baseElement.innerHTML).toMatch(/do not have an artifact/i);
      expect(doc.baseElement.innerHTML).toMatch(/wrong_id/i);
    });

    describe("and then searching for a retrievable artifact", () => {
      beforeEach(() => {
        fetch.mockResponseOnce(JSON.stringify({ files: ["mets.xml"], bag_id: "uuid" }));
        fireSearch("mets_only");
      });

      it("no longer displays the error message", () => {
        expect(doc.baseElement.innerHTML).not.toMatch(/do not have an artifact/i);
        expect(doc.baseElement.innerHTML).not.toMatch(/wrong_id/i);
      });
    });
  });

  describe("when searching for a 403ing artifact", () => {
    beforeEach(() => {
      fetch.mockResponseOnce('Forbidden', { status: 403 });
      fireSearch("2hot2handle")
    });

    it("displays an error message saying the user is unauthorized", () => {
      expect(doc.baseElement.innerHTML).toMatch(/not permitted/i);
      expect(doc.baseElement.innerHTML).toMatch(/2hot2handle/i);
    });
  });

  describe("when searching for a 501ing artifact", () => {
    beforeEach(() => {
      fetch.mockResponseOnce('Not found', { status: 501 });
      fireSearch("uh_oh_its_bad")
    });

    it("displays an internal server error message", () => {
      expect(doc.baseElement.innerHTML).toMatch(/please try again later/i);
    });
  });

  describe("if the api is broken and returning garbage json", () => {
    beforeEach(() => {
      fetch.mockResponseOnce("{{{{{{{{{{");
      fireSearch("uh_oh_its_bad")
    });

    it("displays an internal server error message", () => {
      expect(doc.baseElement.innerHTML).toMatch(/please try again later/i);
    });
  });

  describe("when searching for an artifact with only a mets.xml file", () => {
    beforeEach(() => {
      fetch.mockResponseOnce(JSON.stringify({ files: ["mets.xml"], bag_id: "uuid" }));
      fireSearch("mets_only");
    });

    it("should contain a link to v1/packages/uuid/mets.xml", () => {
      let count = 0;
      const elts = doc.baseElement.getElementsByTagName("a");

      for(let i = 0; i < elts.length; i += 1) {
        if(elts.item(i).getAttribute("href") === "v1/packages/uuid/mets.xml") {
          count += 1;
        }
      }

      expect(count).toEqual(1);
    });

    describe("and then searching for a 404ing artifact", () => {
      beforeEach(() => {
        fetch.mockResponseOnce('Not found', { status: 404 });
        fireSearch("wrong_id")
      });

      it("displays an error message saying we can't find it", () => {
        expect(doc.baseElement.innerHTML).toMatch(/do not have an artifact/i);
        expect(doc.baseElement.innerHTML).toMatch(/wrong_id/i);
      });
    });
  });

  describe("when searching for an artifact with five wav files", () => {
    beforeEach(() => {
      fetch.mockResponseOnce(JSON.stringify(
        { files: ["00000001.wav",
                  "00000002.wav",
                  "00000003.wav",
                  "00000004.wav",
                  "00000005.wav",
                  "mets.xml"],
          bag_id: "ff6cfac9-e8cd-4011-8840-e2c55f8bccea" }));
      fireSearch("five_wavs");
    });

    for(let wav = 1; wav <= 5; wav += 1) {
      let href = "v1/packages/ff6cfac9-e8cd-4011-8840-e2c55f8bccea/0000000" + wav + ".wav";
      it("should contain a link to " + href, () => {
        let count = 0;
        const elts = doc.baseElement.getElementsByTagName("a");

        for(let i = 0; i < elts.length; i += 1) {
          if(elts.item(i).getAttribute("href") === href) {
            count += 1;
          }
        }

        expect(count).toEqual(1);
      });
    }
  });
});

describe('<ArtifactSearch api="https://default.invalid/"/>', () => {
  beforeEach(() => {
    doc = render(
      <MemoryRouter>
        <ArtifactSearch api="https://default.invalid/"/>
      </MemoryRouter>
    );
  });

  it('should call fetch("https://default.invalid/v1/bags/abcd") when the user types in "abcd"', () => {
    fetch.mockResponseOnce();
    fireSearch("abcd");
    expect(fetch.mock.calls.length).toEqual(1);
    expect(fetch.mock.calls[0][0]).toEqual("https://default.invalid/v1/bags/abcd");
  });

  describe("when searching for an artifact with only a mets.xml file", () => {
    beforeEach(() => {
      fetch.mockResponseOnce(JSON.stringify({
        files: ["mets.xml"],
        bag_id: "b5bf33e0-82f0-4b28-b1f2-cac2a56b5ef3"
      }));
      fireSearch("mets_only");
    });

    it("should contain a link to https://default.invalid/v1/packages/b5bf33e0-82f0-4b28-b1f2-cac2a56b5ef3/mets.xml", () => {
      let count = 0;
      const elts = doc.baseElement.getElementsByTagName("a");

      for(let i = 0; i < elts.length; i += 1) {
        if(elts.item(i).getAttribute("href") === "https://default.invalid/v1/packages/b5bf33e0-82f0-4b28-b1f2-cac2a56b5ef3/mets.xml") {
          count += 1;
        }
      }

      expect(count).toEqual(1);
    });
  });
});

describe('<ArtifactSearch value="startingValue"/>', () => {
  beforeEach(() => {
    fetch.mockResponseOnce();
    doc = render(
      <MemoryRouter>
        <ArtifactSearch value="startingValue"/>
      </MemoryRouter>
    );
  });

  it('creates a text input with "startingValue"', () => {
    expect(searchField().getAttribute("value")).toEqual("startingValue");
  });

  it('calls fetch("v1/bags/startingValue") as it loads', () => {
    expect(fetch.mock.calls.length).toEqual(1);
    expect(fetch.mock.calls[0][0]).toEqual("v1/bags/startingValue");
  });
});
