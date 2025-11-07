import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import ReportUpload from '../ReportUpload';
import { props } from '../ReportUpload.fixtures';

describe('ReportUpload', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      render(<ReportUpload />);
      expect(screen.getByRole('button')).toBeInTheDocument();
    });

    it('should render with props', () => {
      render(<ReportUpload {...props} />);
      expect(screen.getByRole('button')).toBeInTheDocument();
    });
  });
});
