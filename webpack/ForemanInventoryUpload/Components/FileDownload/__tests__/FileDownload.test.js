import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import FileDownload from '../FileDownload';

describe('FileDownload', () => {
  it('should render without props', () => {
    render(<FileDownload />);

    expect(screen.getByText('Download Report')).toBeInTheDocument();
  });
});
