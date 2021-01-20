import { Box } from '@bigcommerce/big-design';
import styled from "styled-components";

export const StyledFooter = styled(Box)`
  bottom: 0;
  left: 0;
  position: fixed;
  right: 0;
  z-index: 1;
  background-color: #fff;
  height: 4rem;
  border-top: 1px solid #d9dce9;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding: 0 4rem;
  @media (max-width: 768px) {
    justify-content: center;
    padding: 0;
  }
`;
