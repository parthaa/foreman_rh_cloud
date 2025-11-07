import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import ReportGenerate from '../ReportGenerate';
import { props } from '../ReportGenerate.fixtures';

describe('ReportGenerate', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      render(<ReportGenerate />);
      expect(screen.getByRole('button')).toBeInTheDocument();
    });

    it('should render with props', () => {
      render(<ReportGenerate {...props} />);
      expect(screen.getByRole('button')).toBeInTheDocument();
    });
  });
});
