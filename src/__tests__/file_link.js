import React from "react";
import FileLink from "../file_link";
import {render, cleanup} from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";

let doc;

afterEach(cleanup);

describe('<FileLink>my_file.txt</FileLink>', () => {
  beforeEach(() => {
    doc = render(
      <MemoryRouter>
        <FileLink>my_file.txt</FileLink>
      </MemoryRouter>
    );
  });

  it("has text set to my_file.txt", () => {
    doc.getByText("my_file.txt");
  });

  it("has href set to my_file.txt", () => {
    expect(doc.baseElement.getElementsByTagName('a').item(0).getAttribute("href")).toEqual("my_file.txt");
  });
});

describe('<FileLink base="/v1/packages">mets.xml</FileLink>', () => {
  beforeEach(() => {
    doc = render(
      <MemoryRouter>
        <FileLink base="/v1/packages">mets.xml</FileLink>
      </MemoryRouter>
    );
  });

  it("has text set to mets.xml", () => {
    doc.getByText("mets.xml");
  });

  it("has href set to /v1/packages/mets.xml", () => {
    expect(doc.baseElement.getElementsByTagName('a').item(0).getAttribute("href")).toEqual("/v1/packages/mets.xml");
  });
});
